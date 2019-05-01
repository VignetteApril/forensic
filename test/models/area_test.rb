require "test_helper"

describe Area do
  let(:area) { Area.new }

  it "must be valid" do
    value(area).must_be :valid?
  end
end
