# == Schema Information
#
# Table name: refund_orders
#
#  id                 :bigint           not null, primary key
#  appraisal_cost     :float
#  business_cost      :float
#  appear_court_cost  :float
#  investigation_cost :float
#  consult_cost       :float
#  other_cost         :float
#  refund_cost        :float
#  payee_id           :integer
#  refund_dealer_id   :integer
#  refund_checker_id  :integer
#  total_cost         :float
#  main_case_id       :bigint
#  created_at         :datetime
#  updated_at         :datetime
#  order_stage        :integer          default("not_submit")
#  refund_reason      :string
#  payer              :string
#  payer_contract     :string
#  contract_phone     :string
#  paid_num           :integer
#
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
