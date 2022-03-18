class CreateContractDayTimes < ActiveRecord::Migration[6.1]
  def change
    create_table :contract_day_times do |t|
      t.date :date
      t.datetime :start_time
      t.datetime :end_time
      t.references :contract_day, null: false, foreign_key: true

      t.timestamps
    end
  end
end
