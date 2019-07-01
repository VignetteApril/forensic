class ChangeTakeBillToPaymentOrders < ActiveRecord::Migration[5.2]
  def up
    change_column :payment_orders, :take_bill, :boolean, default: 0
  end

  def down
    change_column :payment_orders, :take_bill, :boolean, default: nil
  end
end
