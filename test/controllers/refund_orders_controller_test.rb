require "test_helper"

describe RefundOrdersController do
  let(:refund_order) { refund_orders :one }

  it "gets index" do
    get refund_orders_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_refund_order_url
    value(response).must_be :success?
  end

  it "creates refund_order" do
    expect {
      post refund_orders_url, params: { refund_order: {  } }
    }.must_change "RefundOrder.count"

    must_redirect_to refund_order_path(RefundOrder.last)
  end

  it "shows refund_order" do
    get refund_order_url(refund_order)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_refund_order_url(refund_order)
    value(response).must_be :success?
  end

  it "updates refund_order" do
    patch refund_order_url(refund_order), params: { refund_order: {  } }
    must_redirect_to refund_order_path(refund_order)
  end

  it "destroys refund_order" do
    expect {
      delete refund_order_url(refund_order)
    }.must_change "RefundOrder.count", -1

    must_redirect_to refund_orders_path
  end
end
