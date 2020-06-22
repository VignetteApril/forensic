class PaymentOrder < ApplicationRecord
  attr_accessor :incoming_record_id
	attr_accessor :claim_user_id
	attr_accessor :data_str

	belongs_to :main_case
	belongs_to :bill, required: false
  has_one :incoming_record # 缴费单和到账记录一一对应
	has_one_attached :attachment


	before_destroy :update_incoming_record_nil
  after_save :update_incoming_record_claimed

  enum order_stage: [:not_submit, :not_confirm, :confirm ,:cancel]
  ORDER_STAGE_MAP = {
      not_submit: '未提交',
      not_confirm: '未确认',
      confirm: '确认',
      cancel: '作废',
  }

	enum payment_accept_type: [:roll, :to_send, :check]
  PAYMENT_ACCEPT_MAP = {
      roll:'摇号',
      to_send:'送达',
      check:'自选',
  }

  # 因为跟到账记录的引用关系，所以在删除前需要把和到账记录的引用去除关联
  def update_incoming_record
    self.incoming_record.update(payment_order_id: nil)
  end

  def update_incoming_record_claimed
    # 如果当前缴费单保存成功，并且传来的参数里还有到账记录id的字段
    # 那么则更新该到账记录为已关联状态，并且
    if !self.incoming_record_id.blank?
      incoming_record = IncomingRecord.find(self.incoming_record_id)
      incoming_record.update(status: :claimed, payment_order_id: self.id, claim_user_id: self.claim_user_id)
    end
	end

  def update_incoming_record_nil
		if !self.incoming_record.nil?
			self.incoming_record.update(payment_order_id: nil, status: :unclaimed, claim_user_id: nil)
		end
	end

	def decode_base64_image data_str
		content_type = data_str[/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/]
		content_type = content_type[/\b(?!.*\/).*/]
		contents = data_str.sub /data:((image|application)\/.{3,}),/, ''
		decoded_data = Base64.decode64(contents)
		filename = 'doc_' + Time.zone.now.to_s + '.' + content_type
		File.open("#{Rails.root}/tmp/#{filename}", 'wb') do |f|
			f.write(decoded_data)
		end
		self.attachment.attach(io: File.open("#{Rails.root}/tmp/#{filename}"), filename: filename)
		FileUtils.rm("#{Rails.root}/tmp/#{filename}")
	end

	class << self
		def take_bill_collection
			[['已开',true],['未开',false]]
		end

		def payment_type_collection
			rs = []
			payment_types.each do |key, value|
				rs << [PAYMENT_TYPE_MAP[key.to_sym], key]
			end
			rs
		end

		def payment_accept_type_collection
			rs = []
			payment_accept_types.each do |key, value|
				rs << [PAYMENT_ACCEPT_MAP[key.to_sym], key]
			end
			rs
		end
	end
end
