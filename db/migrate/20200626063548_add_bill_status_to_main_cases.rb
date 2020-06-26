class AddBillStatusToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :bill_status, :string
  end
end
