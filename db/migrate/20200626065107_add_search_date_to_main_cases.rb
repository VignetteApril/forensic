class AddSearchDateToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :search_date, :date
  end
end
