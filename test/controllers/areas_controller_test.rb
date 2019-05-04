require "test_helper"

describe AreasController do
  it "should get cities" do
    get areas_cities_url
    value(response).must_be :success?
  end

  it "should get districts" do
    get areas_districts_url
    value(response).must_be :success?
  end

end
