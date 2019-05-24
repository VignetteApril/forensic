class AddColumsToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :province_id, :integer
    add_column :main_cases, :city_id, :integer
    add_column :main_cases, :district_id, :integer
  end
end
