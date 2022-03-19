FactoryBot.define do
  factory :service_contract, class: ServiceContract do
    trait :with_contract_days do
      after(:create) do |service, evaluator|
        (1..7).each do |day|
          service.contract_days << FactoryBot.create(:contract_day,
                                                     day_num: day,
                                                     start_time: Time.current.at_middle_of_day + 7.hours,
                                                     end_time: Time.current.at_end_of_day,
                                                     service_contract: service)
        end
      end
    end

    trait :complete_exercise do
      before(:create) do
        FactoryBot::create(:employee, name: "Ernesto", color_tag: "#9CF94A")
        FactoryBot::create(:employee, name: "Barbara", color_tag: "#4AF9E6")
        FactoryBot::create(:employee, name: "Benjamin", color_tag: "#CB86F8")
      end

      after(:create) do |s, evaluator|
        config_contract_days = [
          {
            start_day: 1, end_day: 5,
           start_time: Time.current.at_middle_of_day + 7.hours,
           end_time: Time.current.at_end_of_day
          },
          {
            start_day: 6, end_day: 7,
           start_time: Time.current.at_beginning_of_day + 10.hours,
           end_time: Time.current.at_end_of_day
          }
        ]
        config_contract_days.each do |config_day|
          (config_day[:start_day]..config_day[:end_day]).each do |day|
            s.contract_days << FactoryBot.create(:contract_day,
                                                       :complete_exercise,
                                                       day_num: day,
                                                       start_time: config_day[:start_time],
                                                       end_time: config_day[:end_time],
                                                       service_contract: s)
          end
        end
      end
    end

    company_name { "Recorridos .cl" }
  end
end
