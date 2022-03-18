class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.boolean :checked
      t.boolean :is_confirmed
      t.references :employee, null: false, foreign_key: true
      t.references :contract_day_time, null: false, foreign_key: true

      t.timestamps
    end
  end
end
