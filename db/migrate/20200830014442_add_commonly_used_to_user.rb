class AddCommonlyUsedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :commonly_used, :boolean, default: false
  end
end
