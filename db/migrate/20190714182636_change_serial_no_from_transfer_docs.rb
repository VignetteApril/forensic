class ChangeSerialNoFromTransferDocs < ActiveRecord::Migration[5.2]
  def up
    remove_column :transfer_docs, :serial_no
    add_column :transfer_docs, :serial_no, :integer, default: 0
  end

  def down
    remove_column :transfer_docs, :serial_no, default: 0
    add_column :transfer_docs, :serial_no, :string
  end
end
