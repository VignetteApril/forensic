class RenameIsConfirmToUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :is_confirm, :confirm_stage
  end
end
