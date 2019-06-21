class AddReferenceMainCaseToNotification < ActiveRecord::Migration[5.2]
  def change
  	add_reference :notifications, :main_case
  end
end
