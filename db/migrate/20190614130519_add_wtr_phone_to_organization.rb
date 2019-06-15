class AddWtrPhoneToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :wtr_phone, :string
  end
end
