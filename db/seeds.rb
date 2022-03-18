
c1 = ServiceContract.create!(company_name: 'Recorrido.cl')

e1 = Employee.create!(name: 'Ernesto', color_tag: '#9CF94A')
e2 = Employee.create!(name: 'Barbara', color_tag: '#4AF9E6')
e3 = Employee.create!(name: 'Benjamin', color_tag: '#CB86F8')

next_date = Date.current.next_week.beginning_of_week
contract_days = []
(1..5).each do |day|
  start_time = Time.current.at_middle_of_day + 7.hours # Time.current.at_middle_of_day
  end_time = Time.current.at_end_of_day #Time.tomorrow

  contract_day = ContractDay.create!(day_num: day, start_time: start_time, end_time: end_time, service_contract: c1)
=begin
  next_date += 1.day if day > 1

  last_time = start_time
  next_time = nil
  (start_time.to_i..end_time.to_i).step(1.hour) do |next_hour|
    next_time = Time.at(next_hour)
    ContractDayTime.create!(date: next_date, start_time: last_time, end_time: next_time, contract_day: contract_day)
    last_time = Time.at(next_hour)
  end
=end
  contract_days << contract_day
end

(6..7).each do |day|
  start_time = Time.current.at_beginning_of_day + 10.hours # Time.parse('10:00:00') # Time.current.at_middle_of_day
  end_time = Time.current.at_end_of_day #Time.tomorrow

  contract_day = ContractDay.create!(day_num: day, start_time: start_time, end_time: end_time, service_contract: c1)
end

# check schedule available
=begin
contract_days.each do |cd|
  cd.contract_day_times.each do |s|
    # random to check available, 0,1,2 or 3 employee can check in one time
    [e1, e1, e3].sample(rand(0..3)).each do |employee|
      s.employees << employee
    end
  end
end
=end