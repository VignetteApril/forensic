class AddMainCaseStartNoToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :case_start_no, :integer
  end
end
