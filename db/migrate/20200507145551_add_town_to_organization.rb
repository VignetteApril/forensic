class AddTownToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :town, :string
  end
end
