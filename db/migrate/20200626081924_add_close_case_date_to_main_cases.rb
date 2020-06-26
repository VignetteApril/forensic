class AddCloseCaseDateToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :close_case_date, :date
  end
end
