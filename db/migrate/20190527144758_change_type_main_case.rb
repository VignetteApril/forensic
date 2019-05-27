class ChangeTypeMainCase < ActiveRecord::Migration[5.2]
  def change
    remove_column :transfer_docs, :doc_type
    add_column    :transfer_docs, :doc_type, :string
  end
end
