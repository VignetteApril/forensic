class AddMobilePayToPaymentOrders < ActiveRecord::Migration[5.2]
  def change
  	add_column :payment_orders, :mobile_pay, :float

  end
end
