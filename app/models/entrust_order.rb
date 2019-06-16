class EntrustOrder < ApplicationRecord

	belongs_to :main_case,required:false
	belongs_to :user
	belongs_to :organization
	has_one :appraised_unit
	accepts_nested_attributes_for :appraised_unit, reject_if: :all_blank, allow_destroy: true

	validates :anyou, :presence => true
	validates :case_property, :presence => true

end