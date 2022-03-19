
service_contract = FactoryBot.create(:service_contract, :complete_exercise)

days_week = { monday: "1", tuesday: "2", wednesday: "3", thursday: "4", friday: "5", saturday: "6", sunday: "7"}
employee_ernesto = Employee.find_by(name: "Ernesto")
employee_barbara = Employee.find_by(name: "Barbara")
employee_banjamin = Employee.find_by(name: "Benjamin")

set_data = Hash.new
set_data["#{days_week[:monday]}"] = Hash.new
set_data["#{days_week[:monday]}"]["#{employee_banjamin.id.to_s}"] = { all_day: true, times: [], confirm_all_day: true }
set_data["#{days_week[:tuesday]}"] = Hash.new
set_data["#{days_week[:tuesday]}"]["#{employee_ernesto.id.to_s}"] = { all_day: true, times: [], confirm_all_day: true }
set_data["#{days_week[:tuesday]}"]["#{employee_barbara.id.to_s}"] = { all_day: true, times: [], confirm_all_day: false }
set_data["#{days_week[:tuesday]}"]["#{employee_banjamin.id.to_s}"] = { all_day: true, times: [], confirm_all_day: false }
set_data["#{days_week[:wednesday]}"] = Hash.new
set_data["#{days_week[:wednesday]}"]["#{employee_barbara.id.to_s}"] = { all_day: true, times: [], confirm_all_day: false }
set_data["#{days_week[:wednesday]}"]["#{employee_banjamin.id.to_s}"] = { all_day: true, times: [], confirm_all_day: true }
set_data["#{days_week[:thursday]}"] = Hash.new
set_data["#{days_week[:thursday]}"]["#{employee_ernesto.id.to_s}"] = { all_day: true, times: [], confirm_all_day: true }
set_data["#{days_week[:thursday]}"]["#{employee_barbara.id.to_s}"] = { all_day: true, times: [], confirm_all_day: false }
set_data["#{days_week[:thursday]}"]["#{employee_banjamin.id.to_s}"] = { all_day: true, times: [], confirm_all_day: false }
set_data["#{days_week[:friday]}"] = Hash.new
set_data["#{days_week[:friday]}"]["#{employee_ernesto.id.to_s}"] = { all_day: true, times: [], confirm_all_day: false }
set_data["#{days_week[:friday]}"]["#{employee_barbara.id.to_s}"] = { all_day: true, times: [], confirm_all_day: true }
set_data["#{days_week[:saturday]}"] = Hash.new
set_data["#{days_week[:saturday]}"]["#{employee_ernesto.id.to_s}"] = {
  all_day: false,
  times: %w[10:00-11:00 11:00-12:00 12:00-13:00 13:00-14:00 14:00-15:00],
  confirm_all_day: false,
  times_confirmed_expected: %w[10:00-11:00 11:00-12:00 12:00-13:00 13:00-14:00 14:00-15:00]
}
set_data["#{days_week[:saturday]}"]["#{employee_barbara.id.to_s}"] = {
  all_day: false,
  times: %w[18:00-19:00 19:00-20:00 20:00-21:00],
  confirm_all_day: false,
  times_confirmed_expected: []
}
set_data["#{days_week[:saturday]}"]["#{employee_banjamin.id.to_s}"] = {
  all_day: false,
  times: %w[18:00-19:00 19:00-20:00 20:00-21:00 21:00-22:00 22:00-23:00 23:00-00:00],
  confirm_all_day: false,
  times_confirmed_expected: %w[18:00-19:00 19:00-20:00 20:00-21:00 21:00-22:00 22:00-23:00 23:00-00:00]
}
set_data["#{days_week[:sunday]}"] = {}
set_data["#{days_week[:sunday]}"]["#{employee_barbara.id.to_s}"] = { all_day: true, times: [], confirm_all_day: true }
set_data

start_date = Date.current.next_week.beginning_of_week
end_date = Date.current.next_week.end_of_week
result = Schedule::GetSchedulesService.new(service_contract, start_date, end_date).perform
schedule_array = (result.success?)? result.schedules_array_hash : {}

schedule_array.each_with_index do |schedule_day, schedule_day_index|
  day_num = Date.parse(schedule_day[:date]).cwday
  info_day = set_data[day_num.to_s]
  schedule_day[:times].each_with_index do |schedule_time, schedule_time_index|
    schedule_time[:employees].each_with_index do |employee, employee_index|
      employee_times = info_day[employee[:employee_id].to_s] || nil
      unless employee_times.nil?
        if employee_times[:all_day]
          employee[:checked] = true
        else
          time_range = "#{schedule_time[:start_time]}-#{schedule_time[:end_time]}"
          employee[:checked] = true if employee_times[:times].include?(time_range)
        end
        Schedule.find(employee[:schedule_id]).update(checked: employee[:checked])
      end
    end
  end
end
Schedule::CalculateScheduleConfirmService.new(service_contract, start_date, end_date).perform