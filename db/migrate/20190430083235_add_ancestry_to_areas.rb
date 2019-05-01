class AddAncestryToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :areas, :ancestry, :string
    add_index :areas, :ancestry
  end
end
