FactoryBot.define do
  factory :schedule do
    checked { false }
    is_confirmed { false }
    employee { nil }
    contract_day_time { nil }
  end
end
