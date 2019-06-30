class CreateIncomingRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :incoming_records do |t|
      t.integer :status
      t.string :pay_account
      t.string :pay_person_name
      t.float :amount

      t.timestamps
    end
  end
end
