require "test_helper"

describe CaseUser do
  let(:case_user) { CaseUser.new }

  it "must be valid" do
    value(case_user).must_be :valid?
  end
end
