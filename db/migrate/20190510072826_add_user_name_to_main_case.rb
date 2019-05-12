class AddUserNameToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :user_name, :string
  end
end
