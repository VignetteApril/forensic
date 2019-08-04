class AddClaimUserIdToIncomingRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :incoming_records, :claim_user_id, :integer
  end
end
