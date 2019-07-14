class ChangeNameToRoles < ActiveRecord::Migration[5.2]
  def change
    remove_column :roles, :name
    add_column :roles, :name, :integer
  end
end
