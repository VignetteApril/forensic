class ChangeStatusFromNotifications < ActiveRecord::Migration[5.2]
  def change
    change_column :notifications, :status, :bool, default: false
  end
end
