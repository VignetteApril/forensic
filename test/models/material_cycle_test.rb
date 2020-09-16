# == Schema Information
#
# Table name: material_cycles
#
#  id              :bigint           not null, primary key
#  day             :integer
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

describe MaterialCycle do
  let(:material_cycle) { MaterialCycle.new }

  it "must be valid" do
    value(material_cycle).must_be :valid?
  end
end
