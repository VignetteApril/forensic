class AddTownToReciveExpressOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :recive_express_orders, :town, :string
  end
end
