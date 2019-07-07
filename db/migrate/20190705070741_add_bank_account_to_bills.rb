class AddBankAccountToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :bank_account, :string
    remove_column :bills, :bill_type, :integer
    add_column :bills, :bill_type, :integer
  end
end
