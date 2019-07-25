class AddRecipientToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :recipient, :string
  end
end
