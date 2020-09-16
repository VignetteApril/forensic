# == Schema Information
#
# Table name: case_users
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  main_case_id :bigint
#  pos          :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

describe CaseUser do
  let(:case_user) { CaseUser.new }

  it "must be valid" do
    value(case_user).must_be :valid?
  end
end
