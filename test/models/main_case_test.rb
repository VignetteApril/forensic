require "test_helper"

describe MainCase do
  let(:main_case) { MainCase.new }

  it "must be valid" do
    value(main_case).must_be :valid?
  end
end
