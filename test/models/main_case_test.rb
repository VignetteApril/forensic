# == Schema Information
#
# Table name: main_cases
#
#  id                         :bigint           not null, primary key
#  serial_no                  :string
#  case_no_display            :string
#  user_id                    :integer
#  accept_date                :datetime
#  case_stage                 :integer
#  case_close_date            :datetime
#  case_type                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  user_name                  :string
#  organization_name          :string
#  organization_id            :integer
#  anyou                      :string
#  area_id                    :integer
#  organization_phone         :string
#  organization_addr          :string
#  department_id              :bigint
#  matter                     :text
#  matter_demand              :text
#  base_info                  :text
#  pass_user                  :integer
#  sign_user                  :integer
#  supplement_date            :datetime
#  case_property              :string
#  commission_date            :datetime
#  financial_stage            :integer
#  case_no                    :integer
#  province_id                :integer
#  city_id                    :integer
#  district_id                :integer
#  identification_cycle       :integer
#  material_cycle             :integer
#  ident_users                :string
#  acceptance_date            :datetime
#  wtr_id                     :integer
#  payer                      :string
#  payer_phone                :string
#  amount                     :float
#  wtr_phone                  :string
#  entrust_order_id           :bigint
#  filed_date                 :datetime
#  appraisal_opinion          :string
#  original_appraisal_opinion :string
#  is_repeat                  :boolean          default(FALSE)
#  archive_location           :string
#  payment_method             :string
#  pay_date                   :date
#  bill_status                :string
#  search_date                :date
#  search_type                :string
#  close_case_date            :date
#
require "test_helper"

describe MainCase do
  let(:main_case) { MainCase.new }

  it "must be valid" do
    value(main_case).must_be :valid?
  end
end
