class AddMatterToEntrustOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :entrust_orders, :matter, :text
  end
end
