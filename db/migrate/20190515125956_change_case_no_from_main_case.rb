class ChangeCaseNoFromMainCase < ActiveRecord::Migration[5.2]
  def change
    rename_column :main_cases, :case_no, :case_no_display
    add_column :main_cases, :case_no, :integer
  end
end
