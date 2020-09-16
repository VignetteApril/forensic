require "test_helper"

describe FrequentContactsController do
  let(:frequent_contact) { frequent_contacts(:one) }

  it "should get index" do
    get frequent_contacts_url
    must_respond_with :success
  end

  it "should get new" do
    get new_frequent_contact_url
    must_respond_with :success
  end

  it "should create frequent_contact" do
    assert_difference("FrequentContact.count") do
      post frequent_contacts_url, params: { frequent_contact: { city_id: @frequent_contact.city_id, client_name: @frequent_contact.client_name, district_id: @frequent_contact.district_id, name: @frequent_contact.name, organization_id: @frequent_contact.organization_id, phone: @frequent_contact.phone, province_id: @frequent_contact.province_id } }
    end

    must_redirect_to frequent_contact_url(FrequentContact.last)
  end

  it "should show frequent_contact" do
    get frequent_contact_url(@frequent_contact)
    must_respond_with :success
  end

  it "should get edit" do
    get edit_frequent_contact_url(@frequent_contact)
    must_respond_with :success
  end

  it "should update frequent_contact" do
    patch frequent_contact_url(@frequent_contact), params: { frequent_contact: { city_id: @frequent_contact.city_id, client_name: @frequent_contact.client_name, district_id: @frequent_contact.district_id, name: @frequent_contact.name, organization_id: @frequent_contact.organization_id, phone: @frequent_contact.phone, province_id: @frequent_contact.province_id } }
    must_redirect_to frequent_contact_url(frequent_contact)
  end

  it "should destroy frequent_contact" do
    assert_difference("FrequentContact.count", -1) do
      delete frequent_contact_url(@frequent_contact)
    end

    must_redirect_to frequent_contacts_url
  end
end
