# == Schema Information
#
# Table name: areas
#
#  id         :bigint           not null, primary key
#  name       :string
#  code       :integer
#  area_type  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ancestry   :string
#
require "test_helper"

describe Area do
  let(:area) { Area.new }

  it "must be valid" do
    value(area).must_be :valid?
  end
end
