class AddIdentUsersToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :ident_users, :string
  end
end
