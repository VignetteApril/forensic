class AddRefToIncomingRecords < ActiveRecord::Migration[5.2]
  def change
    add_reference :incoming_records, :payment_order, foreign_key: true
  end
end
