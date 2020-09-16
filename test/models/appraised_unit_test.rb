# == Schema Information
#
# Table name: appraised_units
#
#  id               :bigint           not null, primary key
#  unit_type        :integer
#  name             :string
#  gender           :integer
#  birthday         :datetime
#  id_type          :integer
#  id_num           :string
#  addr             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  main_case_id     :bigint
#  entrust_order_id :bigint
#  wtr_id           :integer
#  unit_contact     :string
#  mobile_phone     :string
#  nationality      :string
#
require "test_helper"

describe AppraisedUnit do
  let(:appraised_unit) { AppraisedUnit.new }

  it "must be valid" do
    value(appraised_unit).must_be :valid?
  end
end
