class CreateEntrustOrder < ActiveRecord::Migration[5.2]
  def change
    create_table :__entrust_orders do |t|
    	t.belongs_to :main_case
    	t.belongs_to :user
    	t.string :case_type
      t.text :matter_demand
      t.text :base_info
      t.string :anyou
      t.timestamps 
    end
  end
end
