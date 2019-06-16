class AddReferenceToAppraisedUnit < ActiveRecord::Migration[5.2]
  def change
  	add_reference :appraised_units, :entrust_order
  end
end
