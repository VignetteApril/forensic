class AddNationalityToAppraisedUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :appraised_units, :nationality, :string
  end
end
