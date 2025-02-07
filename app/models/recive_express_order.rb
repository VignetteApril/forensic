# == Schema Information
#
# Table name: recive_express_orders
#
#  id                 :bigint           not null, primary key
#  sender             :string
#  company_type       :integer
#  content            :string
#  order_date         :datetime
#  order_num          :string
#  main_case_id       :bigint
#  user_id            :bigint
#  case_no            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  reporter           :string
#  receiver_mobile    :string
#  receiver_phone     :string
#  receiver_addr      :string
#  receiver_post_code :integer
#  province_id        :integer
#  city_id            :integer
#  district_id        :integer
#  three_segment_code :string
#  town               :string
#  post_code          :string
#
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
	# after_save :generate_barcode, on: :create
	after_create :set_ems_message

	validates :order_num, :uniqueness => true
	validates :reporter, :receiver_phone, :province_id, :city_id, :receiver_addr, :presence => true

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
		current_order_num = Ems::HttpCaller.request_order_number(self)

		if current_order_num
			self.order_num = current_order_num
			current_three_segment_code = Ems::HttpCaller.request_three_segment_code(self)
			self.three_segment_code = current_three_segment_code
			if self.save
				self.generate_barcode
			else
				raise "生成条码失败"
			end
		else
			raise "获取订单号失败"
		end
  end

  def province_name
		Area.find(self.province_id).name rescue ''
  end

  def city_name
		Area.find(self.city_id).name rescue ''
  end

  def district_name
		Area.find(self.district_id).name rescue ''
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
