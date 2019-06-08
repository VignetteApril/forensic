class ChangeOpenAccountBanckTobankToOrganization < ActiveRecord::Migration[5.2]
  def change
    rename_column :organizations, :open_account_banck, :open_account_bank
  end
end
