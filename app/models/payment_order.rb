class PaymentOrder < ApplicationRecord
	belongs_to :main_case
	belongs_to :bill, required: false 
  has_one :incoming_record # 缴费单和到账记录一一对应


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

  before_destroy :update_incoming_record

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
  #  }
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