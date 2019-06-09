class CreatePaymentOrder < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_orders do |t|

      t.belongs_to :main_case, foreign_key: true
      t.string :payer
      t.string :payer_contacts
      t.string :payer_contacts_phone
      t.string :consigner
      t.string :consiggner_contacts
      t.string :consiggner_contacts_phone

      t.float :appraisal_cost
      t.float :business_cost
      t.float :appear_court_cost
      t.float :investigation_cost
      t.float :other_cost
      t.float :payment_in_advance

      t.integer :payment_type
      t.string :payment_date
      t.string :payment_people
      t.integer :payment_accept_type

      t.timestamps
    end
  end
end
