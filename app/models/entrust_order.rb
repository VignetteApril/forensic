# == Schema Information
#
# Table name: entrust_orders
#
#  id              :bigint           not null, primary key
#  user_id         :bigint
#  case_property   :string
#  matter_demand   :text
#  base_info       :text
#  anyou           :string
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :integer          default("unclaimed")
#  matter          :text
#  department_id   :bigint
#
class EntrustOrder < ApplicationRecord
  has_one :main_case, required: false
  belongs_to :user # 属于某一个委托人
  belongs_to :organization # 属于某一个委托单位
  belongs_to :department, required: false
  has_one :appraised_unit
  accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true
  has_one_attached :entrust_doc # 委托单下的委托书文档

  validates :anyou, :presence => true
  validates :case_property, :presence => true

  enum status: [:unclaimed, :claimed]
  STATUS_MAP = { unclaimed: '未认领',
                 claimed: '已认领'}
end
