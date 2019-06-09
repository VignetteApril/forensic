class RenameWtridInMainCase < ActiveRecord::Migration[5.2]
  def change
    rename_column :main_cases, :wtx_id, :wtr_id
  end
end
