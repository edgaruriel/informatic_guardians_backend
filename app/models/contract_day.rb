class ContractDay < ApplicationRecord
  belongs_to :service_contract
  has_many :contract_day_times, -> { order(date: :asc)}

  validates :day_num, :start_time, :end_time, presence: true
end
