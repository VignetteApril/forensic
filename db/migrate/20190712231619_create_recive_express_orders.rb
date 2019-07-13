class CreateReciveExpressOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :recive_express_orders do |t|
    	t.string :sender
    	t.integer :company_type
    	t.string :content
    	t.datetime :order_date
    	t.string :order_num
    	t.belongs_to :main_case, foreign_key: true
    	t.belongs_to :user, foreign_key: true
    	t.string :case_no

      t.timestamps
    end
  end
end
