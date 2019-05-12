class AddCasePropertyToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :case_property, :string
  end
end
