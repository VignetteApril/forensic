class RefundOrder < ApplicationRecord
	belongs_to :main_case
	
	class << self
		def take_department_user_id(payment_order)
			payment_order.main_case.department.user_array.map{|e|[e.name,e.id]}
		end
	end

	enum order_stage: [:not_submit, :not_confirm, :confirm ,:cancel]
  ORDER_STAGE_MAP = {
      not_submit: '未提交',
      not_confirm: '未确认',
      confirm: '确认',
      cancel: '作废',
  }
end