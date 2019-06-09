class AddTotalCostToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_orders, :total_cost, :float
  end
end
