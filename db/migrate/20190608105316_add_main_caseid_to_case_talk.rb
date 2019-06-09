class AddMainCaseidToCaseTalk < ActiveRecord::Migration[5.2]
  def change
  	add_column   :case_talks, :main_case_id, :integer
  end
end
