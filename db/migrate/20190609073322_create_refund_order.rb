class CreateRefundOrder < ActiveRecord::Migration[5.2]
  def change
    create_table :refund_orders do |t|	
    	t.belongs_to :payment_order, foreign_key: true
    	t.float :appraisal_cost
      t.float :business_cost
      t.float :appear_court_cost
      t.float :investigation_cost
      t.float :consult_cost
      t.float :other_cost

      t.float :refund_cost
      t.integer :payee_id
      t.integer :refund_dealer_id
      t.integer :refund_checker_id
    end
  end
end
