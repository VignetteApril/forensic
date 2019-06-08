class AddPayeeAndOpenAccountBankAndAccountNumberToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :payee, :string
    add_column :organizations, :open_account_banck, :string
    add_column :organizations, :account_number, :string
  end
end
