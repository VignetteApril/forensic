require "test_helper"

describe DocTemplate do
  let(:doc_template) { DocTemplate.new }

  it "must be valid" do
    value(doc_template).must_be :valid?
  end
end
