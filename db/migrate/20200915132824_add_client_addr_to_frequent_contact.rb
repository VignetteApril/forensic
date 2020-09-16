class AddClientAddrToFrequentContact < ActiveRecord::Migration[5.2]
  def change
    add_column :frequent_contacts, :client_addr, :string
  end
end
