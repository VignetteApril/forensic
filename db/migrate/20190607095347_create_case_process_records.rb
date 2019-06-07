class CreateCaseProcessRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :case_process_records do |t|
      t.belongs_to :main_case, foreign_key: true
      t.string :detail

      t.timestamps
    end
  end
end
