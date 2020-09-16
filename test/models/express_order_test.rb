# == Schema Information
#
# Table name: express_orders
#
#  id             :bigint           not null, primary key
#  receiver       :string
#  receiver_addr  :string
#  receiver_phone :string
#  company_type   :integer
#  content        :string
#  order_date     :datetime
#  main_case_id   :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint
#  order_num      :string
#  case_no        :string
#  reporter       :string
#
require "test_helper"

describe ExpressOrder do
  let(:express_order) { ExpressOrder.new }

  it "must be valid" do
    value(express_order).must_be :valid?
  end
end
