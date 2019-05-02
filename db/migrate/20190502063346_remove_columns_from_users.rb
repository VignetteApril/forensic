class RemoveColumnsFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :id_card_no
    remove_column :users, :work_phone
    remove_column :users, :position
    remove_column :users, :code
    remove_column :users, :english_name
    remove_column :users, :politics_status
    remove_column :users, :id_type
    remove_column :users, :marital_status
    remove_column :users, :top_education
    remove_column :users, :top_degree
    remove_column :users, :rank
    remove_column :users, :home_phone
    remove_column :users, :work_fax
    remove_column :users, :email2
    remove_column :users, :country
    remove_column :users, :province
    remove_column :users, :city
    remove_column :users, :zip_code
  end
end