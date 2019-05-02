class AddColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :wechat_id, :string
    add_reference :users, :organization, foreign_key: true
  end
end
