class ChangeMatterInMainCase < ActiveRecord::Migration[5.2]
  def change
    def up
      change_column :main_cases, :matter, :text, array: true, default: []
    end

    def down
      change_column :main_cases, :matter, :text
    end
  end
end
