class AddTemplateIdToDepartmentDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :department_docs, :doc_template_id, :integer
  end
end
