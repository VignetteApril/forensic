class RenameUserColumnOrganizationName < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organization_name, :string
  end
end
