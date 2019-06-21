require "test_helper"

describe EntrustOrdersController do
  let(:entrust_order) { entrust_orders :one }

  it "gets index" do
    get entrust_orders_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_entrust_order_url
    value(response).must_be :success?
  end

  it "creates entrust_order" do
    expect {
      post entrust_orders_url, params: { entrust_order: { anyou: entrust_order.anyou, base_info: entrust_order.base_info, case_property: entrust_order.case_property, main_case_id: entrust_order.main_case_id, matter_demand: entrust_order.matter_demand, organization_id: entrust_order.organization_id, user_id: entrust_order.user_id } }
    }.must_change "EntrustOrder.count"

    must_redirect_to entrust_order_path(EntrustOrder.last)
  end

  it "shows entrust_order" do
    get entrust_order_url(entrust_order)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_entrust_order_url(entrust_order)
    value(response).must_be :success?
  end

  it "updates entrust_order" do
    patch entrust_order_url(entrust_order), params: { entrust_order: { anyou: entrust_order.anyou, base_info: entrust_order.base_info, case_property: entrust_order.case_property, main_case_id: entrust_order.main_case_id, matter_demand: entrust_order.matter_demand, organization_id: entrust_order.organization_id, user_id: entrust_order.user_id } }
    must_redirect_to entrust_order_path(entrust_order)
  end

  it "destroys entrust_order" do
    expect {
      delete entrust_order_url(entrust_order)
    }.must_change "EntrustOrder.count", -1

    must_redirect_to entrust_orders_path
  end
end
