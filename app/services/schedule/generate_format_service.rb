class Schedule::GenerateFormatService < Aldous::Service
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
    {schedules: []}
  end

  def perform
    begin
      schedules = []
      employees = Employee.all.order(:name)
      (start_date..end_date).each do |next_date|
        times_array_hash = []
        hash = {
          date: "#{next_date} 00:00:00"
        }
        contract_day_times = service_contract.contract_day_times.where(date: next_date).order(:start_time)
        contract_day_times.each do |cdt|
          employees_array_hash = []
          cdt.schedules.order(:employee_id).each do |s|
            employees_array_hash << {schedule_id: s.id, employee_id: s.employee.id,
                                     name:s.employee.name, color_tag:s.employee.color_tag,
                                     checked: s.checked, is_confirmed: s.is_confirmed}
          end
          times_array_hash << {start_time: cdt.start_time.strftime("%H:%M"),
                               end_time: cdt.end_time.strftime("%H:%M"),
                               employees: employees_array_hash}
        end
        hash[:times] = times_array_hash
        schedules << hash
      end
      Result::Success.new(schedules: schedules)
    rescue => exception
      Result::Failure.new
    end
  end

  private
  def generate_json

  end
end