# -*- encoding : utf-8 -*-
class CreateSysLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_logs do |t|
      t.integer :user_id
      t.text    :log_content
      t.date    :log_date
      # t.string :user_ip
      # t.string :controller
      # t.string :action
      # t.text :object
      # t.text :error_msg

      t.timestamps null: false
    end
    
    add_index :sys_logs, :log_date
    add_index :sys_logs, :user_id
  end
end
