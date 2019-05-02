class AddIsLockToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_locked, :boolean, default: false
  end
end
