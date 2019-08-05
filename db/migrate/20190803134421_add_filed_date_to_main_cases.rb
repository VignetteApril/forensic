class AddFiledDateToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :filed_date, :timestamp
  end
end
