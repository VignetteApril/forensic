class AddOpenIdToUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :open_id, :string
  end
end
