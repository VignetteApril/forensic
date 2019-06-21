require "test_helper"

describe EntrustOrder do
  let(:entrust_order) { EntrustOrder.new }

  it "must be valid" do
    value(entrust_order).must_be :valid?
  end
end
