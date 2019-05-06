class ChangeColumnStatusInDeparmentDocs < ActiveRecord::Migration[5.2]
  def change
    rename_column :department_docs, :status, :case_stage
  end
end
