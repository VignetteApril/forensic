# == Schema Information
#
# Table name: recive_express_orders
#
#  id                 :bigint           not null, primary key
#  sender             :string
#  company_type       :integer
#  content            :string
#  order_date         :datetime
#  order_num          :string
#  main_case_id       :bigint
#  user_id            :bigint
#  case_no            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  reporter           :string
#  receiver_mobile    :string
#  receiver_phone     :string
#  receiver_addr      :string
#  receiver_post_code :integer
#  province_id        :integer
#  city_id            :integer
#  district_id        :integer
#  three_segment_code :string
#  town               :string
#  post_code          :string
#
require "test_helper"

describe ReciveExpressOrder do
  let(:recive_express_order) { ReciveExpressOrder.new }

  it "must be valid" do
    value(recive_express_order).must_be :valid?
  end
end
