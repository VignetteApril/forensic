class AddRTypeToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :r_type, :integer
  end
end
