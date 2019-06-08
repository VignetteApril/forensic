require "test_helper"

describe CaseProcessRecord do
  let(:case_process_record) { CaseProcessRecord.new }

  it "must be valid" do
    value(case_process_record).must_be :valid?
  end
end
