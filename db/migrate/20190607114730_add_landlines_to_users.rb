class AddLandlinesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :landline, :string
  end
end
