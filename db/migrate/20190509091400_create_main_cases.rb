class CreateMainCases < ActiveRecord::Migration[5.2]
  def change
    create_table :main_cases do |t|
      t.string :serial_no
      t.string :case_no
      t.integer :user_id
      t.timestamp :accept_date
      t.integer :case_stage
      t.timestamp :case_close_date
      t.integer :case_type

      t.timestamps
    end
  end
end
