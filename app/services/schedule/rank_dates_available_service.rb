class Schedule::RankDatesAvailableService < Aldous::Service
  attr_reader :service_contract

  def initialize(service_contract)
    @service_contract = service_contract
  end

  def raisable_error
    Aldous::Errors::ConnectionError
  end

  def default_result_data
    {rank_dates: {start_date: nil, end_date: nil}}
  end

  def perform
    begin
      contract_day_times = service_contract.contract_day_times.order(:date)
      start_date = Date.current.next_week.beginning_of_week
      end_date = Date.current.end_of_week + 5.weeks
      if contract_day_times.size > 0
        start_date = contract_day_times.first.date.beginning_of_week
      end
      Result::Success.new(rank_dates: {start_date: start_date, end_date: end_date})
    rescue Exception => e
      test = true
      Result::Failure.new
    end
  end

  private
  def create_schedules

  end
end