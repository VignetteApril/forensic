class AddOrderStageToRefundOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_orders, :order_stage, :integer, default: 0
  end
end
