class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name
      t.integer :code
      t.string :desc
      t.references :area, foreign_key: true
      t.string :addr
      t.string :phone
      t.string :wechat_id
      t.integer :org_type

      t.timestamps
    end
  end
end
