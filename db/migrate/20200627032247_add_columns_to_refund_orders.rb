class AddColumnsToRefundOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_orders, :payer, :string
    add_column :refund_orders, :payer_contract, :string
    add_column :refund_orders, :contract_phone, :string
  end
end
