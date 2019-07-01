class ChangeOrderStageDefaultToPaymentOrders < ActiveRecord::Migration[5.2]
  def up
    change_column :payment_orders, :order_stage, :integer, default: 0
  end

  def down
    change_column :payment_orders, :order_stage, :integer, default: nil
  end
end
