class Schedule < ApplicationRecord
  belongs_to :employee
  belongs_to :contract_day_time

  validates :employee_id, :contract_day_time_id, presence: true
end
