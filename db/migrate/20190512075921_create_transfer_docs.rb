class CreateTransferDocs < ActiveRecord::Migration[5.2]
  def change
    create_table :transfer_docs do |t|
      t.string :name
      t.integer :doc_type
      t.integer :num
      t.string :unit
      t.string :traits
      t.string :status
      t.timestamp :receive_date
      t.string :barcode
      t.belongs_to :main_case, foreign_key: true

      t.timestamps
    end
  end
end
