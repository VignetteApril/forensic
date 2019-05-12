require "test_helper"

describe MainCasesController do
  let(:main_case) { main_cases :one }

  it "gets index" do
    get main_cases_url
    value(response).must_be :success?
  end

  it "gets new" do
    get new_main_case_url
    value(response).must_be :success?
  end

  it "creates main_case" do
    expect {
      post main_cases_url, params: { main_case: { accept_date: main_case.accept_date, case_close_date: main_case.case_close_date, case_no: main_case.case_no, case_stage: main_case.case_stage, case_type: main_case.case_type, serial_no: main_case.serial_no, user_id: main_case.user_id } }
    }.must_change "MainCase.count"

    must_redirect_to main_case_path(MainCase.last)
  end

  it "shows main_case" do
    get main_case_url(main_case)
    value(response).must_be :success?
  end

  it "gets edit" do
    get edit_main_case_url(main_case)
    value(response).must_be :success?
  end

  it "updates main_case" do
    patch main_case_url(main_case), params: { main_case: { accept_date: main_case.accept_date, case_close_date: main_case.case_close_date, case_no: main_case.case_no, case_stage: main_case.case_stage, case_type: main_case.case_type, serial_no: main_case.serial_no, user_id: main_case.user_id } }
    must_redirect_to main_case_path(main_case)
  end

  it "destroys main_case" do
    expect {
      delete main_case_url(main_case)
    }.must_change "MainCase.count", -1

    must_redirect_to main_cases_path
  end
end
