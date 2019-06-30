class AddRefOrganizationToIncomingRecords < ActiveRecord::Migration[5.2]
  def change
    add_reference :incoming_records, :organization, foreign_key: true
  end
end
