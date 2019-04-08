# -*- encoding : utf-8 -*-
class CreateRoleFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :role_features do |t|
      t.integer :role_id, null: false
      t.integer :feature_id, null: false

      t.timestamps null: false
    end
    
    add_index :role_features, :role_id
    add_index :role_features, :feature_id
  end
end
