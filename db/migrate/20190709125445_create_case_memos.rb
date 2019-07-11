class CreateCaseMemos < ActiveRecord::Migration[5.2]
  def change
    create_table :case_memos do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :main_case, foreign_key: true
      t.string :content
      t.integer :visibility_range

      t.timestamps
    end
  end
end
