class ServiceContract < ApplicationRecord
  has_many :contract_days
  has_many :contract_day_times, through: :contract_days

  validates :company_name, presence: true
end
