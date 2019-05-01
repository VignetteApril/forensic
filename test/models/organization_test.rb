require "test_helper"

describe Organization do
  let(:organization) { Organization.new }

  it "must be valid" do
    value(organization).must_be :valid?
  end
end
