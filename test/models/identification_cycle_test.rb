require "test_helper"

describe IdentificationCycle do
  let(:identification_cycle) { IdentificationCycle.new }

  it "must be valid" do
    value(identification_cycle).must_be :valid?
  end
end
