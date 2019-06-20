class CreateEntrustOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :entrust_orders do |t|
      t.belongs_to :main_case, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.string :case_property
      t.text :matter_demand
      t.text :base_info
      t.string :anyou
      t.belongs_to :organization, foreign_key: true

      t.timestamps
    end
  end
end
