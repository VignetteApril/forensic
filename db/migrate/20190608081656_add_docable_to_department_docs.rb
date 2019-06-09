class AddDocableToDepartmentDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :department_docs, :docable_id, :integer
    add_column :department_docs, :docable_type, :string
    remove_column :department_docs, :department_id
  end
end
