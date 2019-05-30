require "test_helper"

describe MaterialCycle do
  let(:material_cycle) { MaterialCycle.new }

  it "must be valid" do
    value(material_cycle).must_be :valid?
  end
end
