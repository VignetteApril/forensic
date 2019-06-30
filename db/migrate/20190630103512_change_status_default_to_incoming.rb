class ChangeStatusDefaultToIncoming < ActiveRecord::Migration[5.2]
  def up
    change_column :incoming_records, :status, :integer, default: 0
  end

  def down
    change_column :incoming_records, :status, :integer, default: nil
  end
end
