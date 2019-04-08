# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration[5.2][5.2]
  def change
    create_table :users do |t|
      t.string  :login, limit: 50,  null: false
      t.string  :name, limit: 20
      t.string  :id_card_no, limit: 20
      t.string  :email, limit: 100
      t.string  :work_phone, limit: 200
      t.string  :home_phone, limit: 100
      t.string  :work_fax, limit: 100
      t.string  :mobile_phone, limit: 100
      t.string  :email2, limit: 100
      t.string  :position, limit: 100
      t.string  :hashed_password
      t.string  :salt
      t.integer :department_id
      t.string  :code, limit: 100
      t.integer :sort_no
      t.string  :english_name, limit: 100
      t.string  :politics_status, limit: 20
      t.string  :id_type, limit: 20
      t.string  :gender, limit: 10
      t.string  :marital_status, limit: 20
      t.string  :top_education, limit: 20
      t.string  :top_degree, limit: 20
      t.string  :rank, limit: 100
      t.string  :country, limit: 100
      t.string  :province, limit: 100
      t.string  :city, limit: 100
      t.string  :zip_code, limit: 20
      t.string  :address
      t.text    :memo

      t.boolean :changed_password
      t.string :orgnization_name, limit: 20

      t.timestamps null: false
    end

    add_index :users, :department_id
    add_index :users, :sort_no
  end
end
