require "application_system_test_case"

describe "FrequentContacts", :system do
  let(:frequent_contact) { frequent_contacts(:one) }

  it "visiting the index" do
    visit frequent_contacts_url
    assert_selector "h1", text: "Frequent Contacts"
  end

  it "creating a Frequent contact" do
    visit frequent_contacts_url
    click_on "New Frequent Contact"

    fill_in "City", with: @frequent_contact.city_id
    fill_in "Client name", with: @frequent_contact.client_name
    fill_in "District", with: @frequent_contact.district_id
    fill_in "Name", with: @frequent_contact.name
    fill_in "Organization", with: @frequent_contact.organization_id
    fill_in "Phone", with: @frequent_contact.phone
    fill_in "Province", with: @frequent_contact.province_id
    click_on "Create Frequent contact"

    assert_text "Frequent contact was successfully created"
    click_on "Back"
  end

  it "updating a Frequent contact" do
    visit frequent_contacts_url
    click_on "Edit", match: :first

    fill_in "City", with: @frequent_contact.city_id
    fill_in "Client name", with: @frequent_contact.client_name
    fill_in "District", with: @frequent_contact.district_id
    fill_in "Name", with: @frequent_contact.name
    fill_in "Organization", with: @frequent_contact.organization_id
    fill_in "Phone", with: @frequent_contact.phone
    fill_in "Province", with: @frequent_contact.province_id
    click_on "Update Frequent contact"

    assert_text "Frequent contact was successfully updated"
    click_on "Back"
  end

  it "destroying a Frequent contact" do
    visit frequent_contacts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Frequent contact was successfully destroyed"
  end
end
