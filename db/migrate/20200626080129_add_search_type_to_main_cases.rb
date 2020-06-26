class AddSearchTypeToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :search_type, :string
  end
end
