require 'rails_helper'

RSpec.describe Employee, type: :model do
  it "Valid model, present data" do
    dummy = FactoryBot.create(:employee)
    expect(dummy).to be_valid
  end

  it "Invalid model, no present" do
    dummy = FactoryBot.build(:employee, name: "", color_tag: "")
    dummy.save
    expect(dummy.errors.full_messages).to include("Name can't be blank", "Color tag can't be blank")
  end
end
