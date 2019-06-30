class AddReferenceBillToPaymentOrer < ActiveRecord::Migration[5.2]
  def change
  	add_reference :payment_orders, :bill, index: true,foreign_key: true
  end
end
