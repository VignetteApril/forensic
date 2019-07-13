require "test_helper"

describe ExpressOrder do
  let(:express_order) { ExpressOrder.new }

  it "must be valid" do
    value(express_order).must_be :valid?
  end
end
