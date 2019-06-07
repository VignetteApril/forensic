class AddAcceptanceDateToMainCase < ActiveRecord::Migration[5.2]
  def change
    add_column :main_cases, :acceptance_date, :timestamp
  end
end
