class AddSerialNotoTransferDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :transfer_docs, :serial_no, :string
  end
end
