class AddDepartmentNamesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :department_names, :string
  end
end
