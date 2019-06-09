class PaymentOrder < ApplicationRecord
	belongs_to :main_case
	has_many :refund_orders
	has_one :bill

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

end