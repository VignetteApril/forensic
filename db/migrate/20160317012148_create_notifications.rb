# -*- encoding : utf-8 -*-
class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :channel
      t.string :title
      t.string :status
      t.string :url
      t.integer :user_id, null: false

      t.timestamps null: false
    end
    
    add_index :notifications, :user_id
    add_index :notifications, :created_at
  end
end
