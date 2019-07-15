class AddCheckNumToIncomingRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :incoming_records, :check_num, :string
  end
end
