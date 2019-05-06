require "test_helper"

describe DepartmentDocsController do
  let(:department_doc) { department_docs :one }

  it "gets index" do
    get department_docs_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_department_doc_url
    value(response).must_be :success?
  end

  it "creates department_doc" do
    expect {
      post department_docs_url, params: { department_doc: { check_archived: department_doc.check_archived, check_archived_no: department_doc.check_archived_no, doc_code: department_doc.doc_code, filename: department_doc.filename, name: department_doc.name, status: department_doc.status } }
    }.must_change "DepartmentDoc.count"

    must_redirect_to department_doc_path(DepartmentDoc.last)
  end

  it "shows department_doc" do
    get department_doc_url(department_doc)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_department_doc_url(department_doc)
    value(response).must_be :success?
  end

  it "updates department_doc" do
    patch department_doc_url(department_doc), params: { department_doc: { check_archived: department_doc.check_archived, check_archived_no: department_doc.check_archived_no, doc_code: department_doc.doc_code, filename: department_doc.filename, name: department_doc.name, status: department_doc.status } }
    must_redirect_to department_doc_path(department_doc)
  end

  it "destroys department_doc" do
    expect {
      delete department_doc_url(department_doc)
    }.must_change "DepartmentDoc.count", -1

    must_redirect_to department_docs_path
  end
end
