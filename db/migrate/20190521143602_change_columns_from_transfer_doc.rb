class ChangeColumnsFromTransferDoc < ActiveRecord::Migration[5.2]
  def change
    remove_column :transfer_docs, :unit
    add_column    :transfer_docs, :unit, :integer
  end
end
