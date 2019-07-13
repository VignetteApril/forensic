class AddCaseNoToExpressOrder < ActiveRecord::Migration[5.2]
  def change
  	add_column :express_orders, :case_no, :string
  end
end
