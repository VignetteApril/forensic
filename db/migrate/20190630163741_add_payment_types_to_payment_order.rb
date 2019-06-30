class AddPaymentTypesToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column :payment_orders, :cash_pay, :float
  	add_column :payment_orders, :check_pay, :float
  	add_column :payment_orders, :check_num, :string
  	add_column :payment_orders, :card_pay, :float
  	add_column :payment_orders, :remit_pay, :float
  end
end
