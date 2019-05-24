class RenameColumnToOrganization < ActiveRecord::Migration[5.2]
  def change
    rename_column :organizations, :disrict_id, :district_id
  end
end
