# -*- encoding : utf-8 -*-
class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :name, limit: 50, null: false
      t.string :orgnization_name, default: "系统"
      t.string :description

      t.timestamps null: false
    end
  end
end
