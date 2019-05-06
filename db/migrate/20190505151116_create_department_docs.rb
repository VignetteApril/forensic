class CreateDepartmentDocs < ActiveRecord::Migration[5.2]
  def change
    create_table :department_docs do |t|
      t.string :name
      t.string :filename
      t.string :doc_code
      t.integer :status
      t.boolean :check_archived
      t.integer :check_archived_no

      t.timestamps
    end
  end
end
