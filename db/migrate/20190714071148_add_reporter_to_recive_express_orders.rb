class AddReporterToReciveExpressOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :recive_express_orders, :reporter, :string
  end
end
