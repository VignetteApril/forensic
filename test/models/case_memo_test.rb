# == Schema Information
#
# Table name: case_memos
#
#  id               :bigint           not null, primary key
#  user_id          :bigint
#  main_case_id     :bigint
#  content          :string
#  visibility_range :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

describe CaseMemo do
  let(:case_memo) { CaseMemo.new }

  it "must be valid" do
    value(case_memo).must_be :valid?
  end
end
