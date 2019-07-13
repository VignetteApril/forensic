class ExpressOrder < ApplicationRecord
	belongs_to :main_case
	belongs_to :user

	before_save :set_maincase_no, on: [:create, :update]

	validates :order_num, :presence => true, :uniqueness => true

  def set_maincase_no
    self.case_no = self.main_case.case_no
  end

	enum company_type: [:zt, :st, :sf ,:yt]
  COMPANY_TYPE_MAP = {
      zt: '中通',
      st: '申通',
      sf: '顺丰',
      yt: '圆通',
  }

  def my_cases_collection(user)
		rs = []
		my_cases = MainCase.where(:wtr_id=>user.id).try(:all)
		my_cases.each do |c|
			rs << [c.case_no, c.id]
		end
		rs
  end

	class << self
		def company_type_collection
			rs = []
			company_types.each do |key, value|
				rs << [COMPANY_TYPE_MAP[key.to_sym], key]
			end
			rs
		end

		def company_type_reverse
      hash = {}
      ExpressOrder::COMPANY_TYPE_MAP.each{|k, v| hash["#{v}"]=ExpressOrder.check_company_type_index(k.to_sym) }
      return hash
    end

    def check_company_type_index(channel_word)
			company_type = [:zt, :st, :sf ,:yt]
      return company_type.rindex(channel_word)
    end
	end

end
