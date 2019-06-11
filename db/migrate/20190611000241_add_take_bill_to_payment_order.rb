class AddTakeBillToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_orders, :take_bill, :boolean
  end
end
