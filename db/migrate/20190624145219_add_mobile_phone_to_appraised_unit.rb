class AddMobilePhoneToAppraisedUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :appraised_units, :mobile_phone, :string
  end
end
