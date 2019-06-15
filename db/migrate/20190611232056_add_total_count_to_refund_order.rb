class AddTotalCountToRefundOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_orders, :total_cost, :float
  end
end
