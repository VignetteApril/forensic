class AddAmountToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :amount, :integer
  end
end
