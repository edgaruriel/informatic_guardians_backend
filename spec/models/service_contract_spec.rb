require 'rails_helper'

RSpec.describe ServiceContract, type: :model do
  it "Valid model, present data" do
    dummy = FactoryBot.create(:service_contract)
    expect(dummy).to be_valid
  end

  it "Invalid model, no present" do
    dummy = FactoryBot.build(:service_contract, company_name: "")
    dummy.save
    expect(dummy.errors.full_messages).to include("Company name can't be blank")
  end

  it "Valid model relationship, has contract day times" do
    dummy = FactoryBot.create(:service_contract, :with_contract_days)
    expect(dummy.contract_days.size).to eq(7)
  end

end
