class CreateCaseUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :case_users do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :main_case, foreign_key: true
      t.integer :pos

      t.timestamps
    end
  end
end
