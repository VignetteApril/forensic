class AddCreatedAtAndUpdateAtToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :created_at, :timestamp
    add_column :bills, :updated_at, :timestamp
  end
end
