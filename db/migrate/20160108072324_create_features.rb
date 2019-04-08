# -*- encoding : utf-8 -*-
class CreateFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :features do |t|
      t.string :name
      t.string :controller_name
      t.string :action_names
      t.string :app

      t.timestamps null: false
    end
    add_index :features, :controller_name
  end
end
