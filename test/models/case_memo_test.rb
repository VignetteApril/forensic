require "test_helper"

describe CaseMemo do
  let(:case_memo) { CaseMemo.new }

  it "must be valid" do
    value(case_memo).must_be :valid?
  end
end
