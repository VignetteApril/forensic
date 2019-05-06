class AddDepartmentRerToDepartmentDocs < ActiveRecord::Migration[5.2]
  def change
    add_reference :department_docs, :department, foreign_key: true
  end
end
