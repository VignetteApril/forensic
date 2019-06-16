class RefundOrder < ApplicationRecord
	belongs_to :payment_order

	class << self
		def take_department_user_id(payment_order)
			payment_order.main_case.department.user_array.map{|e|[e.name,e.id]}
		end
	end
end