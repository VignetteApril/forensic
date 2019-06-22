class AddWtridToAppraisedUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :appraised_units, :wtr_id, :integer
  end
end
