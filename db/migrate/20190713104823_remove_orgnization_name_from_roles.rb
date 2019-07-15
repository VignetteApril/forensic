class RemoveOrgnizationNameFromRoles < ActiveRecord::Migration[5.2]
  def change
    remove_column :roles, :orgnization_name
  end
end
