# == Schema Information
#
# Table name: refund_orders
#
#  id                 :bigint           not null, primary key
#  appraisal_cost     :float
#  business_cost      :float
#  appear_court_cost  :float
#  investigation_cost :float
#  consult_cost       :float
#  other_cost         :float
#  refund_cost        :float
#  payee_id           :integer
#  refund_dealer_id   :integer
#  refund_checker_id  :integer
#  total_cost         :float
#  main_case_id       :bigint
#  created_at         :datetime
#  updated_at         :datetime
#  order_stage        :integer          default("not_submit")
#  refund_reason      :string
#  payer              :string
#  payer_contract     :string
#  contract_phone     :string
#  paid_num           :integer
#
require "test_helper"

describe RefundOrder do
  let(:refund_order) { RefundOrder.new }

  it "must be valid" do
    value(refund_order).must_be :valid?
  end
end
