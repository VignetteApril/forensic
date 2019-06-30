require "test_helper"

describe IncomingRecord do
  let(:incoming_record) { IncomingRecord.new }

  it "must be valid" do
    value(incoming_record).must_be :valid?
  end
end
