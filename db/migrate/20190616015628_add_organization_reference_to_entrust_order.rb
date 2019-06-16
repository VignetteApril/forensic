class AddOrganizationReferenceToEntrustOrder < ActiveRecord::Migration[5.2]
  def change
  	add_reference :entrust_orders, :organization
  end
end
