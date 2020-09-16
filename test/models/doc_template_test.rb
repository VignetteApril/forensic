# == Schema Information
#
# Table name: doc_templates
#
#  id         :bigint           not null, primary key
#  name       :string
#  desc       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

describe DocTemplate do
  let(:doc_template) { DocTemplate.new }

  it "must be valid" do
    value(doc_template).must_be :valid?
  end
end
