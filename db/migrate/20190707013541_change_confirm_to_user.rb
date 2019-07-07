class ChangeConfirmToUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :confirm_stage
  	add_column :users, :confirm_stage, :integer, default: 2
  end
end
