# == Schema Information
#
# Table name: express_orders
#
#  id             :bigint           not null, primary key
#  receiver       :string
#  receiver_addr  :string
#  receiver_phone :string
#  company_type   :integer
#  content        :string
#  order_date     :datetime
#  main_case_id   :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint
#  order_num      :string
#  case_no        :string
#  reporter       :string
#
class ExpressOrder < ApplicationRecord
	belongs_to :main_case
	belongs_to :user
	attr_accessor :come_from

	before_save :set_maincase_no, on: [:create, :update]

	validates :order_num, :presence => true, :uniqueness => true

  def set_maincase_no
    self.case_no = self.main_case.case_no
  end

	enum company_type: [:ems]
  COMPANY_TYPE_MAP = {
			ems: 'EMS'
  }

  def my_cases_collection(user)
		rs = []
  	if user.client_entrust_user?
			my_cases = MainCase.where(:wtr_id=>user.id).try(:all)
			my_cases.each do |c|
				rs << [c.serial_no, c.id]
			end
			return rs
		else
			if user.departments.nil?
       	if (user.center_director_user? || user.center_admin_user? || center_archivist_user? || center_finance_user?)
       		# 返回机构案件
       		org_cases = @current_user.organization.main_cases
		   		org_cases.each do |c|
						rs << [c.serial_no, c.id]
					end
					return rs    		
				else
					return
				end
			else
				# 返回科室案件
				department_cases = MainCase.where(:department_id => user.departments.split(','))
	   		department_cases.each do |c|
					rs << [c.serial_no, c.id]
				end
				return rs    
			end
		end
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
