class CreateExpressOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :express_orders do |t|
    	
    	t.string :receiver
    	t.string :receiver_addr
    	t.string :receiver_phone
    	t.integer :company_type
    	t.string :content
    	t.datetime :order_date
    	t.belongs_to :main_case, foreign_key: true

      t.timestamps
    end
  end
end
