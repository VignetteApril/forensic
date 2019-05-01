require "test_helper"

describe OrganizationsController do
  let(:organization) { organizations :one }

  it "gets index" do
    get organizations_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_organization_url
    value(response).must_be :success?
  end

  it "creates organization" do
    expect {
      post organizations_url, params: { organization: { addr: organization.addr, area_id: organization.area_id, code: organization.code, desc: organization.desc, name: organization.name, phone: organization.phone, wechat_id: organization.wechat_id } }
    }.must_change "Organization.count"

    must_redirect_to organization_path(Organization.last)
  end

  it "shows organization" do
    get organization_url(organization)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_organization_url(organization)
    value(response).must_be :success?
  end

  it "updates organization" do
    patch organization_url(organization), params: { organization: { addr: organization.addr, area_id: organization.area_id, code: organization.code, desc: organization.desc, name: organization.name, phone: organization.phone, wechat_id: organization.wechat_id } }
    must_redirect_to organization_path(organization)
  end

  it "destroys organization" do
    expect {
      delete organization_url(organization)
    }.must_change "Organization.count", -1

    must_redirect_to organizations_path
  end
end
