class Schedule::UpdateSchedulesService < Aldous::Service
  attr_reader :service_contract, :start_date, :end_date, :schedules_array

  def initialize(service_contract, start_date, end_date, schedules_array)
    @schedules_array = schedules_array
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
      employees = schedules_array.map { |schedule| schedule['times'].map {|t| t['employees']} }
      employees = employees.flatten
      employees.each do |hash|
        schedule = Schedule.find(hash['schedule_id'])
        schedule.update!(checked: hash['checked'])
      end

      Schedule::CalculateScheduleConfirmService.new(service_contract, start_date, end_date).perform
      result = Schedule::GetSchedulesService.new(service_contract, start_date, end_date).perform

      Result::Success.new(schedules_array_hash: result.schedules_array_hash)
    rescue Exception => e
      test = true
      Result::Failure.new
    end
  end

  private
  def create_schedules

  end
end