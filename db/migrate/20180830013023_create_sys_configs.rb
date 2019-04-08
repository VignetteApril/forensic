class CreateSysConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_configs do |t|
      t.string :key
      t.string :value
      t.text :desc
      t.string :gem

      t.timestamps null: false
    end
  end
end
