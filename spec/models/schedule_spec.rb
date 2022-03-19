require 'rails_helper'

RSpec.describe Schedule, type: :model do

  it "Valid model, present data" do
    schedule = FactoryBot.create(:schedule, :with_employee_and_contract_day_time)
    expect(schedule).to be_valid
  end

  it "Invalid model, no present data" do
    schedule = FactoryBot.build(:schedule)
    schedule.save
    expect(schedule.errors.full_messages).to include("Employee must exist")
    expect(schedule.errors.full_messages).to include("Contract day time must exist")
    expect(schedule.errors.full_messages).to include("Employee can't be blank")
    expect(schedule.errors.full_messages).to include("Contract day time can't be blank")
  end


end
