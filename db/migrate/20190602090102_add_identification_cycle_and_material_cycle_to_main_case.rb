class AddIdentificationCycleAndMaterialCycleToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :identification_cycle, :integer
    add_column :main_cases, :material_cycle, :integer
  end
end
