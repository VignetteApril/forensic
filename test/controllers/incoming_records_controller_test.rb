require "test_helper"

describe IncomingRecordsController do
  let(:incoming_record) { incoming_records :one }

  it "gets index" do
    get incoming_records_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_incoming_record_url
    value(response).must_be :success?
  end

  it "creates incoming_record" do
    expect {
      post incoming_records_url, params: { incoming_record: { amount: incoming_record.amount, pay_account: incoming_record.pay_account, pay_person_name: incoming_record.pay_person_name, status: incoming_record.status } }
    }.must_change "IncomingRecord.count"

    must_redirect_to incoming_record_path(IncomingRecord.last)
  end

  it "shows incoming_record" do
    get incoming_record_url(incoming_record)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_incoming_record_url(incoming_record)
    value(response).must_be :success?
  end

  it "updates incoming_record" do
    patch incoming_record_url(incoming_record), params: { incoming_record: { amount: incoming_record.amount, pay_account: incoming_record.pay_account, pay_person_name: incoming_record.pay_person_name, status: incoming_record.status } }
    must_redirect_to incoming_record_path(incoming_record)
  end

  it "destroys incoming_record" do
    expect {
      delete incoming_record_url(incoming_record)
    }.must_change "IncomingRecord.count", -1

    must_redirect_to incoming_records_path
  end
end
