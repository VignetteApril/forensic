class CreateAppraisedUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :appraised_units do |t|
      t.integer :unit_type
      t.string :name
      t.integer :gender
      t.timestamp :birthday
      t.integer :id_type
      t.string :id_num
      t.string :addr

      t.timestamps
    end
  end
end
