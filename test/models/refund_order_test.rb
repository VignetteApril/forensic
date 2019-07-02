require "test_helper"

describe RefundOrder do
  let(:refund_order) { RefundOrder.new }

  it "must be valid" do
    value(refund_order).must_be :valid?
  end
end
