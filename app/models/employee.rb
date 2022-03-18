class Employee < ApplicationRecord
  has_many :schedules, -> {where is_confirmed: true}
  has_and_belongs_to_many :contract_day_times, join_table: 'schedules'

  validates :name, :color_tag, presence: true
end
