class Schedule::GetSchedulesService < Aldous::Service
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
      schedules = []
      if service_contract.contract_day_times.between_date(start_date.to_s, end_date.to_s).size > 0
        result = Schedule::GenerateFormatService.new(service_contract, start_date, end_date).perform
        schedules = result.schedules
      end

      Result::Success.new(schedules_array_hash: schedules)
    rescue => exception
      Result::Failure.new
    end
  end
end