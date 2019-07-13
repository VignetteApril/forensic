require "test_helper"

describe ReciveExpressOrder do
  let(:recive_express_order) { ReciveExpressOrder.new }

  it "must be valid" do
    value(recive_express_order).must_be :valid?
  end
end
