class AddAssistIdentUserToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :assist_ident_user, :integer
  end
end
