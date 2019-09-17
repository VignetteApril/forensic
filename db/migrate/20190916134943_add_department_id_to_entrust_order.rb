class AddDepartmentIdToEntrustOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :entrust_orders, :department, foreign_key: true
  end
end
