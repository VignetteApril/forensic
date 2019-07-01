require "test_helper"

describe BillsController do
  let(:bill) { bills :one }

  it "gets index" do
    get bills_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_bill_url
    value(response).must_be :success?
  end

  it "creates bill" do
    expect {
      post bills_url, params: { bill: {  } }
    }.must_change "Bill.count"

    must_redirect_to bill_path(Bill.last)
  end

  it "shows bill" do
    get bill_url(bill)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_bill_url(bill)
    value(response).must_be :success?
  end

  it "updates bill" do
    patch bill_url(bill), params: { bill: {  } }
    must_redirect_to bill_path(bill)
  end

  it "destroys bill" do
    expect {
      delete bill_url(bill)
    }.must_change "Bill.count", -1

    must_redirect_to bills_path
  end
end
