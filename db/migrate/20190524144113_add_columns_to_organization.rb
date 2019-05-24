class AddColumnsToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :province_id, :integer
    add_column :organizations, :city_id, :integer
    add_column :organizations, :disrict_id, :integer
  end
end
