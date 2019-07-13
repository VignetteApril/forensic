class AddReferenceUserToExpressOrder < ActiveRecord::Migration[5.2]
  def change
  	add_reference :express_orders, :user, index: true,foreign_key: true
  end
end
