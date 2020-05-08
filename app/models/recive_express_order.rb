require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'ems'

class ReciveExpressOrder < ApplicationRecord
	belongs_to :main_case
	belongs_to :user
	has_one_attached :barcode_image
	attr_accessor :come_from

	before_save :set_maincase_no, on: [:create, :update]
	after_save :generate_barcode, on: :create
	after_create :set_ems_message

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

  # 设置案件的顺序号
  def generate_barcode
		barcode = Barby::Code128.new(self.order_num)
		blob = Barby::PngOutputter.new(barcode).to_png
		self.barcode_image.attach io: StringIO.new(blob),
								  filename: self.order_num + '.png',
								  content_type: 'image/png'
  end

  # 根据当前的信息，去ems取订单号，三段码，如果失败则，订单创建失败
  def set_ems_message
	
  end

  def province_name
		Area.find(self.province_id).name
  end

  def city_name
		Area.find(self.city_id).name
  end

  def district_name
		Area.find(self.district_id).name
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
		  ReciveExpressOrder::COMPANY_TYPE_MAP.each{|k, v| hash["#{v}"]=ReciveExpressOrder.check_company_type_index(k.to_sym) }
		  return hash
		end

		def check_company_type_index(channel_word)
				company_type = [:zt, :st, :sf ,:yt]
		  return company_type.rindex(channel_word)
		end
	end
end
