class ChangeIsConfirmToUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_confirm
  	add_column :users, :is_confirm, :integer, default: 0
  end
end
