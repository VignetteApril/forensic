class PaymentOrder < ApplicationRecord
  attr_accessor :incoming_record_id

	belongs_to :main_case
	belongs_to :bill, required: false 
  has_one :incoming_record # 缴费单和到账记录一一对应

  after_save :update_incoming_record_claimed

  enum order_stage: [:not_submit, :not_confirm, :confirm ,:cancel]
  ORDER_STAGE_MAP = {
      not_submit: '未提交',
      not_confirm: '未确认',
      confirm: '确认',
      cancel: '作废',
  }

	enum payment_accept_type: [:roll, :roll1,]
  PAYMENT_ACCEPT_MAP = {
      roll: '摇号',
      roll1: '摇号1'
  }

  # 因为跟到账记录的引用关系，所以在删除前需要把和到账记录的引用去除关联
  def update_incoming_record
    self.incoming_record.update(payment_order_id: nil)
  end

  # enum payment_type: [:cash, :card, :remit, :check]
  #  PAYMENT_TYPE_MAP = {
  #      cash: '现金',
  #      card: '刷卡',
  #      remit: '汇款',
  #      check: '支票'
  #      wechat: '微信'
  #  }

  def update_incoming_record_claimed
    # 如果当前缴费单保存成功，并且传来的参数里还有到账记录id的字段
    # 那么则更新该到账记录为已关联状态，并且
    if !self.incoming_record_id.blank?
      incoming_record = IncomingRecord.find(self.incoming_record_id)
      incoming_record.update(status: :claimed, payment_order_id: self.id)
    end
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