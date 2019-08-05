class AddRemarksToIncomingRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :incoming_records, :remarks, :string
  end
end
