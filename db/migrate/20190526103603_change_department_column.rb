class ChangeDepartmentColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :department_id
    add_column    :users, :departments, :string
  end
end
