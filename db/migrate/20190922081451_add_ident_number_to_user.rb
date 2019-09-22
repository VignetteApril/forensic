class AddIdentNumberToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ident_number, :string
  end
end
