class AddOrderNumToExpressOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column :express_orders, :order_num, :string
  end
end
