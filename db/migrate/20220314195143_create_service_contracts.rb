class CreateServiceContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :service_contracts do |t|
      t.string :company_name

      t.timestamps
    end
  end
end
