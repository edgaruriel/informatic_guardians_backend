class Schedule::CreateSchedulesService < Aldous::Service
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
      schedules = Schedule::GetSchedulesService.new(service_contract, start_date, end_date).perform
      if schedules.success? && schedules.schedules_array_hash.size == 0
        create_schedules
      end
      result = Schedule::GetSchedulesService.new(service_contract, start_date, end_date).perform
      schedules = result.schedules_array_hash

      Result::Success.new(schedules_array_hash: schedules)
    rescue Exception => e
      Result::Failure.new
    end
  end

  private
  def create_schedules
    employees = Employee.all
    service_contract.contract_days.each do |contract_day|
      day_num = contract_day.day_num
      date = (start_date..end_date).select { |d| day_num.to_i === d.cwday.to_i }.first
      date_time = date.to_time
      start_time = (date_time + contract_day.start_time.hour.hours).to_datetime
      end_time = (date_time + contract_day.end_time.hour.hours).to_datetime

      schedules = []

      last_time = start_time
      hour_step = (1.to_f/24)
      (start_time + 1.hour).step((end_time + 1.hour),hour_step).each do |next_hour|
        cdt = ContractDayTime.create!(date: date, start_time: last_time, end_time: next_hour, contract_day: contract_day)
        employees.each do |e| cdt.employees << e end
        schedules << cdt
        last_time = next_hour
      end
    end
  end
end