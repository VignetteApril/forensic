class AddAppraisalOpinionAndOrgToMainCases < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :appraisal_opinion, :string
    add_column :main_cases, :original_appraisal_opinion, :string
    add_column :main_cases, :is_repeat, :boolean, default: false
  end
end
