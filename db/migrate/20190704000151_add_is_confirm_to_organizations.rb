class AddIsConfirmToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :is_confirm, :boolean
  end
end
