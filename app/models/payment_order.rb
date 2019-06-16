class PaymentOrder < ApplicationRecord
	belongs_to :main_case
	has_one :bill

	has_many :refund_orders
	accepts_nested_attributes_for :refund_orders, reject_if: :all_blank, allow_destroy: true

	enum payment_type: [:cash, :card, :remit, :check]
  PAYMENT_TYPE_MAP = {
      cash: '现金',
      card: '刷卡',
      remit: '汇款',
      check: '支票'
  }

	enum payment_accept_type: [:roll, :roll1,]
  PAYMENT_ACCEPT_MAP = {
      roll: '摇号',
      roll1: '摇号1'
  }


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