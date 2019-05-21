class AddCaseTypesToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :case_types, :string
  end
end
