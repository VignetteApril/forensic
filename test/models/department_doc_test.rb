require "test_helper"

describe DepartmentDoc do
  let(:department_doc) { DepartmentDoc.new }

  it "must be valid" do
    value(department_doc).must_be :valid?
  end
end
