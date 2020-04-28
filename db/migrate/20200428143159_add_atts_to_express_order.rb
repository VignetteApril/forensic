class AddAttsToExpressOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :recive_express_orders, :receiver_mobile, :string
    add_column :recive_express_orders, :receiver_phone, :string
    add_column :recive_express_orders, :receiver_addr, :string
    add_column :recive_express_orders, :receiver_post_code, :integer
    add_column :recive_express_orders, :province_id, :integer
    add_column :recive_express_orders, :city_id, :integer
    add_column :recive_express_orders, :district_id, :integer
    add_column :recive_express_orders, :three_segment_code, :string
  end
end
