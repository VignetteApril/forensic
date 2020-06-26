class AddPayDateToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :pay_date, :date
  end
end
