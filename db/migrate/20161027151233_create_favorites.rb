# -*- encoding : utf-8 -*-
class CreateFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :favorites do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.text :url, null: false

      t.timestamps null: false
    end
  end
end
