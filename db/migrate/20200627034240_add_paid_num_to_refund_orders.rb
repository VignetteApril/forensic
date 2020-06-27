class AddPaidNumToRefundOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_orders, :paid_num, :integer
  end
end
