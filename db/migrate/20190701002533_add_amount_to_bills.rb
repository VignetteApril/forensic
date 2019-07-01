class AddAmountToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :amount, :float
  end
end
