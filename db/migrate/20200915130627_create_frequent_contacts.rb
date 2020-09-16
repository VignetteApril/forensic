class CreateFrequentContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :frequent_contacts do |t|
      t.string :name
      t.integer :province_id
      t.integer :city_id
      t.integer :district_id
      t.integer :organization_id
      t.string :client_name
      t.string :phone

      t.timestamps
    end
  end
end
