# == Schema Information
#
# Table name: organizations
#
#  id                :bigint           not null, primary key
#  name              :string
#  code              :integer
#  desc              :string
#  area_id           :bigint
#  addr              :string
#  phone             :string
#  wechat_id         :string
#  org_type          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ancestry          :string
#  abbreviation      :string
#  province_id       :integer
#  city_id           :integer
#  district_id       :integer
#  payee             :string
#  open_account_bank :string
#  account_number    :string
#  level             :string
#  is_confirm        :boolean          default(TRUE)
#  town              :string
#  post_code         :string
#
require "test_helper"

describe Organization do
  let(:organization) { Organization.new }

  it "must be valid" do
    value(organization).must_be :valid?
  end
end
