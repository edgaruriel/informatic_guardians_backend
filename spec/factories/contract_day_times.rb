FactoryBot.define do
  factory :contract_day_time do
    trait :with_contract_days do

      before(:create) do |contract_day_time, evaluator|
        service = FactoryBot.create(:service_contract, :with_contract_days)
        contract_day = service.contract_days.first

        date = DateTime.current.end_of_week + contract_day.day_num.days
        date_time = date.to_time
        start_time = (date_time + contract_day.start_time.hour.hours).to_datetime

        contract_day_time.contract_day = contract_day
        contract_day_time.date = date
        contract_day_time.start_time = start_time
        contract_day_time.end_time = start_time + 1.hour
      end
    end

    trait :complete_exercise do
      after(:create) do |c, evaluator|
        Employee.all.each do |e|
          FactoryBot.create(:schedule, employee: e, contract_day_time: c)
        end
      end
    end
  end
end
