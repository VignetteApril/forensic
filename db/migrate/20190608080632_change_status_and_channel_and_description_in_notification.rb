class ChangeStatusAndChannelAndDescriptionInNotification < ActiveRecord::Migration[5.2]
  def change
    remove_column :notifications, :channel
    add_column    :notifications, :channel, :integer
    remove_column :notifications, :status
    add_column    :notifications, :status, :boolean    
    add_column    :notifications, :description, :text    
  end
end
