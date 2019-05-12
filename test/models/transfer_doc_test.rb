require "test_helper"

describe TransferDoc do
  let(:transfer_doc) { TransferDoc.new }

  it "must be valid" do
    value(transfer_doc).must_be :valid?
  end
end
