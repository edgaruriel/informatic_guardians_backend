
c1 = ServiceContract.create!(company_name: 'Recorrido.cl')

e1 = Employee.create!(name: 'Ernesto', color_tag: '#9CF94A')
e2 = Employee.create!(name: 'Barbara', color_tag: '#4AF9E6')
e3 = Employee.create!(name: 'Benjamin', color_tag: '#CB86F8')

next_date = Date.current.next_week.beginning_of_week
contract_days = []
(1..5).each do |day|
  start_time = Time.current.at_middle_of_day + 7.hours
  end_time = Time.current.at_end_of_day

  contract_day = ContractDay.create!(day_num: day, start_time: start_time, end_time: end_time, service_contract: c1)

  contract_days << contract_day
end

(6..7).each do |day|
  start_time = Time.current.at_beginning_of_day + 10.hours
  end_time = Time.current.at_end_of_day

  contract_day = ContractDay.create!(day_num: day, start_time: start_time, end_time: end_time, service_contract: c1)
end
