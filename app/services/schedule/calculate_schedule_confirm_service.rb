class Schedule::CalculateScheduleConfirmService < Aldous::Service
  attr_reader :service_contract, :start_date, :end_date

  def initialize(service_contract, start_date, end_date)
    @service_contract = service_contract
    @start_date = start_date
    @end_date = end_date
  end

  def raisable_error
    Aldous::Errors::ConnectionError
  end

  def default_result_data
    {schedules_array_hash: []}
  end

  def perform
    begin
      @times_confirmed_global = confirm_times_nonblock
      summary_days = get_summary_times_block
      summary_days.each do |s|
        if s[:min_hour_block] < s[:hours_total_day]
          determinate_assign_hours(s)
        else
          employees_involved = s[:employee_times].keys
          employee_min_hour = fetch_employee_min_hour(employees_involved)
          employee_id = employee_min_hour[:employee_id]
          schedules = s[:employee_times][employee_id][:schedules]
          update_schedule_confirm(schedules, employee_id)
        end
      end

      Result::Success.new(schedules_array_hash: [])
    rescue Exception => e
      test_calculate = 1
      test2 = 1
      Result::Failure.new
    end
  end

  private
  attr_reader :times_confirmed_global

  def update_schedule_confirm(schedules, employee_id)
    total_hours = 0
    schedules.each do |s|
      s.update!(is_confirmed: true)
      total_hours += 1
    end
    times_confirmed_global[employee_id] += total_hours
  end

  def fetch_employee_min_hour(employees)
    min_hour = {employee_id: nil, hours: 0}
    times_confirmed_global.keys.each do |employee_id|
      next unless employees.include?(employee_id)
      if min_hour[:employee_id] == nil || times_confirmed_global[employee_id] < min_hour[:hours]
        min_hour = { employee_id: employee_id, hours: times_confirmed_global[employee_id] }
      end
    end
    min_hour
  end

  def get_sql_hours_checked
    "
    SELECT contract_day_times.id, contract_day_times.start_time, COUNT(DISTINCT (s.employee_id)) as amount_checked
            FROM contract_day_times
                INNER JOIN schedules s on contract_day_times.id = s.contract_day_time_id
                INNER JOIN contract_days cd on contract_day_times.contract_day_id = cd.id
            WHERE (contract_day_times.date BETWEEN '#{start_date}' AND '#{end_date}')
              AND s.checked = true
              AND cd.service_contract_id = '#{service_contract.id}'
            group by contract_day_times.id, contract_day_times.start_time
    "
  end

  def confirm_times_nonblock
    service_contract.contract_day_times.between_date(start_date.to_s, end_date.to_s).each do |t|
      t.schedules.update_all(is_confirmed: false) # reset schedules confirmed
    end
    # return contract_day_times nonblock, only one employee checked the hour
    sql_select = "SELECT * FROM (#{get_sql_hours_checked}) as times_checked WHERE times_checked.amount_checked = 1;"
    times_schedules_nonblock = ActiveRecord::Base.connection.execute(sql_select)
    times_confirmed_employee = {}
    times_schedules_nonblock.map do |t|
      schedule = ContractDayTime.find(t['id']).schedules.where(checked: true).first
      times_confirmed_employee["#{schedule.employee.id.to_s}"] ||= 0
      times_confirmed_employee["#{schedule.employee.id.to_s}"] += 1
      schedule.update(is_confirmed: true)
    end
    Employee.all.each do |e|
      times_confirmed_employee["#{e.id.to_s}"] ||= 0
    end
    times_confirmed_employee
  end

  def get_summary_times_block
    sql_select = "SELECT * FROM (#{get_sql_hours_checked}) as times_block
        WHERE times_block.amount_checked > 1 ORDER BY times_block.amount_checked DESC;"
    times_schedules_block = ActiveRecord::Base.connection.execute(sql_select)
    summary = {}
    times_schedules_block.each do |t|
      cdt = ContractDayTime.find(t['id'])
      time_employee = summary["#{cdt.date.strftime("%F")}"] || { employee_times: {}, contract_day_times: []}
      time_employee[:contract_day_times] << cdt
      cdt.schedules.where(checked: true).each do |s|
        time_employee[:employee_times]["#{s.employee.id.to_s}"] ||= {hours: 0, schedules: []}
        employee_summary = time_employee[:employee_times]["#{s.employee.id.to_s}"]
        employee_summary[:hours] += 1
        employee_summary[:schedules] << s
        time_employee[:employee_times]["#{s.employee.id.to_s}"] = employee_summary
      end
      summary["#{cdt.date.strftime("%F")}"] = time_employee
    end
    summary_times_array = []
    summary.keys.each do |k|
      employee_times = summary[k][:employee_times].values.map { |e| e[:hours] }
      hours_total = service_contract.contract_day_times.where(date: k).size # each record contract_day_times is equal 1 hour
      summary_times_array << { date: k,
                               employee_times: summary[k][:employee_times],
                               contract_day_times: summary[k][:contract_day_times],
                               min_hour_block: employee_times.min,
                               hours_total_day: hours_total }
    end
    summary_times_array.sort_by { |s| s[:min_hour_block] }
  end

  def determinate_assign_hours(summary_time)
    contract_day_times = summary_time[:contract_day_times].sort_by { |cdt| cdt.start_time }
    hour_step = (1.to_f/24)
    contract_day_times_by_date = service_contract.contract_day_times.where(date: contract_day_times.first.date)
    end_time_day = contract_day_times_by_date.order(end_time: :desc).first.end_time
    start_time_day = contract_day_times_by_date.order(start_time: :asc).first.start_time

    contract_day_times.each do |c| # are the hours that has conflict hours between employees
      next if c.schedules.exists?(is_confirmed: true)

      candidate_evaluates = []
      summary_time[:employee_times].keys.each { |employee_id|
        candidate_evaluates << { employee_id: employee_id,
                                 next_hours: 0 ,
                                 back_hours: 0,
                                 next_schedules_no_confirmed: [] } if c.schedules.exists?(employee_id: employee_id, checked: true)
      }
      start_time = c.start_time + 1.hour
      next_hours = iterate_date_times(start_time, end_time_day)
      candidate_evaluates = get_continuous_hours(candidate_evaluates, next_hours, :next_hours)

      start_time = start_time_day
      end_time_schedule = c.start_time - 1.hour
      back_hours = iterate_date_times(start_time, end_time_schedule).reverse!

      candidate_evaluates = get_continuous_hours(candidate_evaluates, back_hours, :back_hours)

      apply_rules_confirm_hour(candidate_evaluates, c)
    end
  end

  def iterate_date_times(start_time, end_time_schedule)
    hour_step = (1.to_f/24)
    hours = []
    (start_time.to_datetime).step((end_time_schedule.to_datetime),hour_step).each { |next_time| hours << next_time }
    hours
  end

  def apply_rules_confirm_hour(candidate_evaluates, contract_day_time)
    has_next_hours_equal = candidate_evaluates.map { |c| c[:next_hours] }.uniq.length == 1
    has_back_hours_equal = candidate_evaluates.map { |c| c[:back_hours] }.uniq.length == 1
    schedules = []
    if has_next_hours_equal && has_back_hours_equal # confirm all schedule of employee to not change between employees in the same date
      employee_ids = candidate_evaluates.map { |c| c[:employee_id] }
      candidate_finish = fetch_employee_min_hour(employee_ids)
      candidate_data = candidate_evaluates.find { |c| c[:employee_id] === candidate_finish[:employee_id] }
      schedules = candidate_data[:next_schedules_no_confirmed]
    else
      candidate_finish = candidate_evaluates.max_by { |ce| ce[:next_hours] }
      candidate_finish = candidate_evaluates.max_by { |ce| ce[:back_hours] } if candidate_finish[:next_hours] === 0
    end
    schedules += contract_day_time.schedules.where(employee_id: candidate_finish[:employee_id], checked: true)
    update_schedule_confirm(schedules, candidate_finish[:employee_id])
  end

  def get_continuous_hours(candidate_evaluates, hours_day, key_group)
    candidate_evaluates.each do |employee|
      found_time_no_checked = false
      backup_hours = []
      hours_day.each { |h| backup_hours << h }
      while backup_hours.length > 0 && !found_time_no_checked
        start_time = backup_hours.shift
        conditions = {employee_id: employee[:employee_id], checked: true}
        conditions[:is_confirmed] = true if key_group.equal?(:back_hours)
        contract_day_times_employee = service_contract.contract_day_times.includes(:employees)
                                         .where(start_time: start_time, schedules: conditions)
        if contract_day_times_employee.size > 0
          employee[key_group] += 1
          if key_group.equal?(:next_hours)
            schedule_no_confirmed = contract_day_times_employee.first.schedules.where(is_confirmed: false, employee_id: employee[:employee_id])
            employee[:next_schedules_no_confirmed] << schedule_no_confirmed.first if schedule_no_confirmed.size > 0
          end
        else
          found_time_no_checked = true
        end
      end
    end
    candidate_evaluates
  end
end