class AddMatterToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :matter, :string
  end
end
