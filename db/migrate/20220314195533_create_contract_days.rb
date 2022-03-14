class CreateContractDays < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_days do |t|
      t.integer :day_num
      t.time :start_time
      t.time :end_time
      t.references :service_contract, null: false, foreign_key: true

      t.timestamps
    end
  end
end
