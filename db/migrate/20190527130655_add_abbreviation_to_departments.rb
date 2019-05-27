class AddAbbreviationToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :departments, :abbreviation, :string
  end
end
