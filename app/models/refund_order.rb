class RefundOrder < ApplicationRecord
	belongs_to :payment_order

	class << self
		def take_department_user_id(payment_order)
			payment_order.main_case.department.user_array.map{|e|[e.name,e.id]}
			# [['小白','1'],['小明','2'],['小刚','3']]
		end 
	end
end