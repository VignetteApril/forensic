# == Schema Information
#
# Table name: identification_cycles
#
#  id              :bigint           not null, primary key
#  day             :integer
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

describe IdentificationCycle do
  let(:identification_cycle) { IdentificationCycle.new }

  it "must be valid" do
    value(identification_cycle).must_be :valid?
  end
end
