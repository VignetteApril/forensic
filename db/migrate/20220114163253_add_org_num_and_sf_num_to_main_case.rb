class AddOrgNumAndSfNumToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :org_case_number, :string
    add_column :main_cases, :forensic_case_number, :string
  end
end
