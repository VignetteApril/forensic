class AddMainCaseToAppraisedUnits < ActiveRecord::Migration[5.2]
  def change
    add_reference :appraised_units, :main_case, foreign_key: true
  end
end
