class RenameCaseTypeToEntrustOrder < ActiveRecord::Migration[5.2]
  def change
    rename_column :entrust_orders, :case_type, :case_property
  end
end
