class AddRecipientDateToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :recipient_date, :timestamp
  end
end
