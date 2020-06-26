class AddRefundReasonToRefundOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_orders, :refund_reason, :string
  end
end
