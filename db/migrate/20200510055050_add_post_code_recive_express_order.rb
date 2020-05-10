class AddPostCodeReciveExpressOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column :recive_express_orders, :post_code, :string
  	add_column :organizations, :post_code, :string
  end
end
