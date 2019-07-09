class AddIsPassedToDepartmentDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :department_docs, :is_passed, :boolean, default: false
  end
end
