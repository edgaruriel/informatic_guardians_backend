class ContractDayTime < ApplicationRecord
  belongs_to :contract_day
  has_many :schedules
  has_and_belongs_to_many :employees, join_table: 'schedules'
  scope :between_date, -> (start_date, end_date) { where('date BETWEEN ? AND ?', start_date, end_date) }

  validates :date, :start_time, :end_time, presence: true
  validates :contract_day, presence: true
  validates_date :date, on_or_before: lambda { Date.current.end_of_week + 5.weeks }
  validates_date :date, on_or_after: lambda { Date.current.next_week.beginning_of_week }
end
