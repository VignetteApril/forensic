# == Schema Information
#
# Table name: incoming_records
#
#  id               :bigint           not null, primary key
#  status           :integer          default("unclaimed")
#  pay_account      :string
#  pay_person_name  :string
#  amount           :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pay_date         :datetime
#  pay_type         :integer
#  payment_order_id :bigint
#  organization_id  :bigint
#  check_num        :string
#  remarks          :string
#  claim_user_id    :integer
#
require "test_helper"

describe IncomingRecord do
  let(:incoming_record) { IncomingRecord.new }

  it "must be valid" do
    value(incoming_record).must_be :valid?
  end
end
