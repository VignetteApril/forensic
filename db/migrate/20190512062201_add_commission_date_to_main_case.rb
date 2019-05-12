class AddCommissionDateToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :commission_date, :timestamp
  end
end
