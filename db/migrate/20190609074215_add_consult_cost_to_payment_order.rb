class AddConsultCostToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column  :payment_orders, :consult_cost, :float
  end
end
