class AddCityIdAndDistrictIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :province_id, :integer
    add_column :users, :city_id, :integer
    add_column :users, :district_id, :integer
  end
end
