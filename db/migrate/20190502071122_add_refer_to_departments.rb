class AddReferToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_reference :departments, :organization, foreign_key: true
  end
end
