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
require "test_helper"

describe FrequentContact do
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end
end
