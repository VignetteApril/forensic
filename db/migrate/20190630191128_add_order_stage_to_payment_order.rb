class AddOrderStageToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column :payment_orders, :order_stage, :integer
  end
end
