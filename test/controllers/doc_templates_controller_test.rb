require "test_helper"

describe DocTemplatesController do
  let(:doc_template) { doc_templates :one }

  it "gets index" do
    get doc_templates_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_doc_template_url
    value(response).must_be :success?
  end

  it "creates doc_template" do
    expect {
      post doc_templates_url, params: { doc_template: { desc: doc_template.desc, name: doc_template.name } }
    }.must_change "DocTemplate.count"

    must_redirect_to doc_template_path(DocTemplate.last)
  end

  it "shows doc_template" do
    get doc_template_url(doc_template)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_doc_template_url(doc_template)
    value(response).must_be :success?
  end

  it "updates doc_template" do
    patch doc_template_url(doc_template), params: { doc_template: { desc: doc_template.desc, name: doc_template.name } }
    must_redirect_to doc_template_path(doc_template)
  end

  it "destroys doc_template" do
    expect {
      delete doc_template_url(doc_template)
    }.must_change "DocTemplate.count", -1

    must_redirect_to doc_templates_path
  end
end
