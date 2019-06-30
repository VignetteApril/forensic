class RemoveColumnsPaymentOrderToBill < ActiveRecord::Migration[5.2]
  def change
    add_reference :bills, :main_case, index: true,foreign_key: true
    remove_reference :bills, :payment_order, index: true
  end
end
