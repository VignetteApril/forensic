class AddFinancialStageToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :financial_stage, :integer
  end
end
