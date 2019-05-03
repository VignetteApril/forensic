class RemoveColumnsFromDepartments < ActiveRecord::Migration[5.2]
  def change
    remove_column :departments, :brief
    remove_column :departments, :admin_level
    remove_column :departments, :role_type
    remove_column :departments, :contact
    remove_column :departments, :orgnization_name
  end
end
