class AddWtridToMainCase < ActiveRecord::Migration[5.2]
  def change
  	add_column :main_cases, :wtx_id, :integer
  end
end
