class AddFormIdToUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :form_id, :string
  end
end
