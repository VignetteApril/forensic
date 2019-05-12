require "test_helper"

describe AppraisedUnit do
  let(:appraised_unit) { AppraisedUnit.new }

  it "must be valid" do
    value(appraised_unit).must_be :valid?
  end
end
