class AddColumnsToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :organization_name, :string
    add_column :main_cases, :organization_id, :integer
    add_column :main_cases, :anyou, :string
    add_column :main_cases, :area_id, :integer
    add_column :main_cases, :organization_phone, :string
    add_column :main_cases, :organization_addr, :string
    add_reference :main_cases, :department, foreign_key: true
    add_column :main_cases, :matter, :string
    add_column :main_cases, :matter_demand, :text
    add_column :main_cases, :base_info, :text
    add_column :main_cases, :pass_user, :integer
    add_column :main_cases, :sign_user, :integer
    add_column :main_cases, :supplement_date, :timestamp
  end
end
