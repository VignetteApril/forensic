class AddAppToFeatures < ActiveRecord::Migration[5.2]
  def change
    add_column :features, :app, :string
  end
end
