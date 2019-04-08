class AddSessionIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :session_id, :string
  end
end
