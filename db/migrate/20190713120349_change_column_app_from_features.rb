class ChangeColumnAppFromFeatures < ActiveRecord::Migration[5.2]
  def change
    rename_column :features, :app, :role_names
  end
end
