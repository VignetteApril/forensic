# -*- encoding : utf-8 -*-
class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.string  :name,        limit: 200, null: false
      t.text    :description
      t.string  :parent_id
      t.string  :ancestry
      t.string  :brief,       limit: 100
      t.integer :sort_no
      t.string  :code,        limit: 20,  null: false, default: '0000000000'
      t.string  :admin_level, limit: 100
      t.string  :role_type,   limit: 100
      t.string  :contact
      t.string  :orgnization_name

      t.timestamps null: false
    end

    add_index :departments, :sort_no
    add_index :departments, :ancestry
  end
end
