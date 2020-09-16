# == Schema Information
#
# Table name: entrust_orders
#
#  id              :bigint           not null, primary key
#  user_id         :bigint
#  case_property   :string
#  matter_demand   :text
#  base_info       :text
#  anyou           :string
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :integer          default("unclaimed")
#  matter          :text
#  department_id   :bigint
#
require "test_helper"

describe EntrustOrder do
  let(:entrust_order) { EntrustOrder.new }

  it "must be valid" do
    value(entrust_order).must_be :valid?
  end
end
