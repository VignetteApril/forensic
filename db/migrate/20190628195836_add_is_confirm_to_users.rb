class AddIsConfirmToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_confirm, :boolean
  end
end
