class RenameTypeToBill < ActiveRecord::Migration[5.2]
  def change
    rename_column :bills, :type, :bill_type
  end
end
