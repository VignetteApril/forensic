class ChangeMattersInMainCases < ActiveRecord::Migration[5.2]
  def change
    change_column :main_cases, :matter, :text
  end
end
