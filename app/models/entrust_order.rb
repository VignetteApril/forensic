class EntrustOrder < ApplicationRecord
  belongs_to :main_case, required:false
  belongs_to :user
  belongs_to :organization
  has_one :appraised_unit
  accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true
  has_one_attached :entrust_doc # 委托单下的委托书

  validates :anyou, :presence => true
  validates :case_property, :presence => true

end
