class AddPayDateAndPayTypeToIncomingRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :incoming_records, :pay_date, :timestamp
    add_column :incoming_records, :pay_type, :integer
  end
end
