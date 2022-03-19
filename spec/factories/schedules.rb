FactoryBot.define do
  factory :schedule do
    trait :with_employee_and_contract_day_time do
      before(:create) do |s, evaluator|
        s.employee = FactoryBot.create(:employee)
        s.contract_day_time = FactoryBot.create(:contract_day_time, :with_contract_days)
      end
    end
  end
end
