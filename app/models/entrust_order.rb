class EntrustOrder < ApplicationRecord
  has_one :main_case, required:false
  belongs_to :user # 属于某一个委托人
  belongs_to :organization # 属于某一个委托单位
  belongs_to :department
  has_one :appraised_unit
  accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true
  has_one_attached :entrust_doc # 委托单下的委托书文档

  validates :anyou, :presence => true
  validates :case_property, :presence => true

  enum status: [:unclaimed, :claimed]
  STATUS_MAP = { unclaimed: '未认领',
                 claimed: '已认领'}
end
