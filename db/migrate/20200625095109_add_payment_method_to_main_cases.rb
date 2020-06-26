class AddPaymentMethodToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :payment_method, :string
  end
end
