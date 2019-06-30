class PaymentOrdersController < ApplicationController
	layout 'system'
  skip_before_action :can 

	def new
		@main_case = MainCase.find(params["main_case_id"])
		@payment_order = @main_case.payment_orders.new
	end

	def create
		@order = PaymentOrder.new(payment_order_params)
		@order.order_stage = :not_submit
		@order.main_case_id = params["main_case_id"]
		if @order.save
			 redirect_to payment_order_management_main_case_path(MainCase.find(params["main_case_id"])), notice: '缴费单已经成功创建了！' 
		end
	end

	def edit
	end


	private

	 def payment_order_params
	 	params.require(:payment_order).permit( :payer,
	                                         :payer_contacts,
	                                         :payer_contacts_phone,
	                                         :consigner,
	                                         :consiggner_contacts,
	                                         :consiggner_contacts_phone,
	                                         :appraisal_cost,
	                                         :business_cost,
	                                         :appear_court_cost,
	                                         :investigation_cost,
	                                         :other_cost,
	                                         :consult_cost,
	                                         :total_cost,
	                                         :remit_pay,
	                                         :payment_date,
	                                         :payment_people,
	                                         :payment_in_advance,
	                                         :cash_pay,
	                                         :card_pay,
	                                         :check_pay,
	                                         :check_num)

	 end


end