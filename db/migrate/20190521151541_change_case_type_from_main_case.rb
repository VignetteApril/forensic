class ChangeCaseTypeFromMainCase < ActiveRecord::Migration[5.2]
  def change
    change_column :main_cases, :case_type, :string
  end
end
