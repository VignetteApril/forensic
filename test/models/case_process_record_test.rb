# == Schema Information
#
# Table name: case_process_records
#
#  id           :bigint           not null, primary key
#  main_case_id :bigint
#  detail       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

describe CaseProcessRecord do
  let(:case_process_record) { CaseProcessRecord.new }

  it "must be valid" do
    value(case_process_record).must_be :valid?
  end
end
