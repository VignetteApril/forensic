require "test_helper"

describe MaterialCyclesController do
  let(:material_cycle) { material_cycles :one }

  it "gets index" do
    get material_cycles_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_material_cycle_url
    value(response).must_be :success?
  end

  it "creates material_cycle" do
    expect {
      post material_cycles_url, params: { material_cycle: { day: material_cycle.day, organization_id: material_cycle.organization_id } }
    }.must_change "MaterialCycle.count"

    must_redirect_to material_cycle_path(MaterialCycle.last)
  end

  it "shows material_cycle" do
    get material_cycle_url(material_cycle)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_material_cycle_url(material_cycle)
    value(response).must_be :success?
  end

  it "updates material_cycle" do
    patch material_cycle_url(material_cycle), params: { material_cycle: { day: material_cycle.day, organization_id: material_cycle.organization_id } }
    must_redirect_to material_cycle_path(material_cycle)
  end

  it "destroys material_cycle" do
    expect {
      delete material_cycle_url(material_cycle)
    }.must_change "MaterialCycle.count", -1

    must_redirect_to material_cycles_path
  end
end
