FactoryBot.define do
  factory :contract_day do
    trait :complete_exercise do
      after(:create) do |c, evaluator|
        day_num = c.day_num
        date = Date.current.end_of_week + day_num.days
        date_time = date.to_time
        start_time = (date_time + c.start_time.hour.hours).to_datetime
        end_time = (date_time + c.end_time.hour.hours).to_datetime

        schedules = []

        last_time = start_time
        hour_step = (1.to_f/24)
        (start_time + 1.hour).step((end_time + 1.hour),hour_step).each do |next_hour|
          cdt = FactoryBot.create(:contract_day_time, :complete_exercise, date: date, start_time: last_time, end_time: next_hour, contract_day: c)
          last_time = next_hour
        end
      end
    end

    day_num { 1 }
    start_time { "2022-03-14 13:55:33" }
    end_time { "2022-03-14 13:55:33" }
    service_contract { nil }
  end
end
