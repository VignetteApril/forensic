require "test_helper"

describe IdentificationCyclesController do
  let(:identification_cycle) { identification_cycles :one }

  it "gets index" do
    get identification_cycles_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_identification_cycle_url
    value(response).must_be :success?
  end

  it "creates identification_cycle" do
    expect {
      post identification_cycles_url, params: { identification_cycle: { day: identification_cycle.day, organization_id: identification_cycle.organization_id } }
    }.must_change "IdentificationCycle.count"

    must_redirect_to identification_cycle_path(IdentificationCycle.last)
  end

  it "shows identification_cycle" do
    get identification_cycle_url(identification_cycle)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_identification_cycle_url(identification_cycle)
    value(response).must_be :success?
  end

  it "updates identification_cycle" do
    patch identification_cycle_url(identification_cycle), params: { identification_cycle: { day: identification_cycle.day, organization_id: identification_cycle.organization_id } }
    must_redirect_to identification_cycle_path(identification_cycle)
  end

  it "destroys identification_cycle" do
    expect {
      delete identification_cycle_url(identification_cycle)
    }.must_change "IdentificationCycle.count", -1

    must_redirect_to identification_cycles_path
  end
end
