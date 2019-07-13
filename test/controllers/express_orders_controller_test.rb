require "test_helper"

describe ExpressOrdersController do
  let(:express_order) { express_orders :one }

  it "gets index" do
    get express_orders_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_express_order_url
    value(response).must_be :success?
  end

  it "creates express_order" do
    expect {
      post express_orders_url, params: { express_order: {  } }
    }.must_change "ExpressOrder.count"

    must_redirect_to express_order_path(ExpressOrder.last)
  end

  it "shows express_order" do
    get express_order_url(express_order)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_express_order_url(express_order)
    value(response).must_be :success?
  end

  it "updates express_order" do
    patch express_order_url(express_order), params: { express_order: {  } }
    must_redirect_to express_order_path(express_order)
  end

  it "destroys express_order" do
    expect {
      delete express_order_url(express_order)
    }.must_change "ExpressOrder.count", -1

    must_redirect_to express_orders_path
  end
end
