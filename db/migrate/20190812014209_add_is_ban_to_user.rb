class AddIsBanToUser < ActiveRecord::Migration[5.2]
  def change
    add_column  :users, :is_ban, :boolean, default: false
  end
end
