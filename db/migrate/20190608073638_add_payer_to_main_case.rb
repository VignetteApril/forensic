class AddPayerToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :payer, :string
    add_column :main_cases, :payer_phone, :string
  end
end
