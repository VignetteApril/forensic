class AddStatusToEntrustOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :entrust_orders, :status, :integer, default: 0
  end
end
