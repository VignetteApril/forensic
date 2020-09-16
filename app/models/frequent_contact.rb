# == Schema Information
#
# Table name: frequent_contacts
#
#  id              :bigint           not null, primary key
#  name            :string
#  province_id     :integer
#  city_id         :integer
#  district_id     :integer
#  organization_id :integer
#  client_name     :string
#  phone           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_addr     :string
#
class FrequentContact < ApplicationRecord
  belongs_to :organization, optional: true
  validates :name, uniqueness: { scope: [:client_name, :organization_id, :phone] }
  validates :name, :client_name, presence: true

  def province_name
    Area.find(self.province_id).name rescue ''
  end

  def city_name
    Area.find(self.city_id).name rescue ''
  end

  def district_name
    Area.find(self.district_id).name rescue ''
  end
end
