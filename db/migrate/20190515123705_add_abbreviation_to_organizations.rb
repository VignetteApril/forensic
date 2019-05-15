class AddAbbreviationToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :abbreviation, :string
  end
end
