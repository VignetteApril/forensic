class ChangeIsConfirmToOrgnization < ActiveRecord::Migration[5.2]
  def change
    remove_column :organizations, :is_confirm
  	add_column :organizations, :is_confirm, :boolean, default: true
  end
end
