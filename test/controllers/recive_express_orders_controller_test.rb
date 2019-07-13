require "test_helper"

describe ReciveExpressOrdersController do
  let(:recive_express_order) { recive_express_orders :one }

  it "gets index" do
    get recive_express_orders_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_recive_express_order_url
    value(response).must_be :success?
  end

  it "creates recive_express_order" do
    expect {
      post recive_express_orders_url, params: { recive_express_order: {  } }
    }.must_change "ReciveExpressOrder.count"

    must_redirect_to recive_express_order_path(ReciveExpressOrder.last)
  end

  it "shows recive_express_order" do
    get recive_express_order_url(recive_express_order)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_recive_express_order_url(recive_express_order)
    value(response).must_be :success?
  end

  it "updates recive_express_order" do
    patch recive_express_order_url(recive_express_order), params: { recive_express_order: {  } }
    must_redirect_to recive_express_order_path(recive_express_order)
  end

  it "destroys recive_express_order" do
    expect {
      delete recive_express_order_url(recive_express_order)
    }.must_change "ReciveExpressOrder.count", -1

    must_redirect_to recive_express_orders_path
  end
end
