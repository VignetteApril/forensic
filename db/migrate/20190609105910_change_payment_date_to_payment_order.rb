class ChangePaymentDateToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :payment_orders, :payment_date
    add_column :payment_orders, :payment_date, :timestamp
    change_column :main_cases, :amount, :float
  end
end
