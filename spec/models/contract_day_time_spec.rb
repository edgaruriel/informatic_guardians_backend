require 'rails_helper'

RSpec.describe ContractDayTime, type: :model do

  it "Valid model, present data" do
    dummy = FactoryBot.create(:contract_day_time, :with_contract_days)
    expect(dummy).to be_valid
  end

  it "Invalid model, no present data" do
    dummy = FactoryBot.build(:contract_day_time)
    dummy.save
    expect(dummy.errors.full_messages).to include("Contract day must exist")
    expect(dummy.errors.full_messages).to include("Date can't be blank")
    expect(dummy.errors.full_messages).to include("Start time can't be blank")
    expect(dummy.errors.full_messages).to include("End time can't be blank")
    expect(dummy.errors.full_messages).to include("Contract day can't be blank")
    expect(dummy.errors.full_messages).to include("Date is not a valid date")
  end

  it "Valid model, date range between 5 weeks forward beginning the following Monday" do
    accepted_last_date = Date.current.end_of_week + 5.weeks
    accepted_start_date = Date.current.next_week.beginning_of_week
    contract_day_time_last = FactoryBot.build(:contract_day_time, date: Date.current + 4.weeks)
    contract_day_time_start = FactoryBot.build(:contract_day_time, date: Date.current.next_week)

    contract_day_time_last.save
    contract_day_time_start.save
    expect(contract_day_time_last.errors.full_messages).not_to include("Date must be on or before #{accepted_last_date}")
    expect(contract_day_time_start.errors.full_messages).not_to include("Date must be on or after #{accepted_start_date}")
  end

  it "Invalid model, out of date range between 5 weeks forward beginning the following Monday" do
    accepted_last_date = Date.current.end_of_week + 5.weeks
    accepted_start_date = Date.current.next_week.beginning_of_week
    contract_day_time_last = FactoryBot.build(:contract_day_time, date: Date.current + 6.weeks)
    contract_day_time_start = FactoryBot.build(:contract_day_time, date: Date.current)

    contract_day_time_last.save
    contract_day_time_start.save
    expect(contract_day_time_last.errors.full_messages).to include("Date must be on or before #{accepted_last_date}")
    expect(contract_day_time_start.errors.full_messages).to include("Date must be on or after #{accepted_start_date}")
  end
end
