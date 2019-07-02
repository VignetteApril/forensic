class AddCreateAtAndUpdateToRefundOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_orders, :created_at, :timestamp
    add_column :refund_orders, :updated_at, :timestamp
  end
end
