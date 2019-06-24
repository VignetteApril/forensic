class AddUnitContactToAppraisedUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :appraised_units, :unit_contact, :string
  end
end
