class CreateCaseTalks < ActiveRecord::Migration[5.2]
  def change
    create_table :case_talks do |t|
   	  t.integer :user_id
      t.string :detail
      t.timestamps
    end
  end
end
