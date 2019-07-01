class AddBillStageToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :bill_stage, :integer, default: 0
  end
end
