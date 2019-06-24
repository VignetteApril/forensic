class AddEntrustOderIdToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_reference :main_cases, :entrust_order, foreign_key: true
    remove_reference :entrust_orders, :main_case, index: true, foreign_key: true
  end
end
