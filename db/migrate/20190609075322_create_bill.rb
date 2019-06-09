class CreateBill < ActiveRecord::Migration[5.2]
  def change
    create_table :bills do |t|
    	t.belongs_to :payment_order, foreign_key: true
      t.string :type
      t.string :organization
      t.string :address
      t.string :code
      t.string :bank
      t.string :phone
    end
  end
end
