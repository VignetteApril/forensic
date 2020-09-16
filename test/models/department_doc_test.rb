# == Schema Information
#
# Table name: department_docs
#
#  id                :bigint           not null, primary key
#  name              :string
#  filename          :string
#  doc_code          :string
#  case_stage        :integer
#  check_archived    :boolean
#  check_archived_no :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  doc_template_id   :integer
#  docable_id        :integer
#  docable_type      :string
#  is_passed         :boolean          default(FALSE)
#
require "test_helper"

describe DepartmentDoc do
  let(:department_doc) { DepartmentDoc.new }

  it "must be valid" do
    value(department_doc).must_be :valid?
  end
end
