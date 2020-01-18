class AddArchiveLocationToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :archive_location, :string
  end
end
