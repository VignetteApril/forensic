require "test_helper"

describe EditOfficeOnlineController do
  it "should get edit_office" do
    get edit_office_online_edit_office_url
    value(response).must_be :success?
  end

end
