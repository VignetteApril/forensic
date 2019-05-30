class CreateMaterialCycles < ActiveRecord::Migration[5.2]
  def change
    create_table :material_cycles do |t|
      t.integer :day
      t.belongs_to :organization, foreign_key: true

      t.timestamps
    end
  end
end
