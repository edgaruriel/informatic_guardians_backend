class Schedule < ApplicationRecord
  belongs_to :employee
  belongs_to :contract_day_time
end
