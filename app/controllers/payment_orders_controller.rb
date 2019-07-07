class PaymentOrdersController < ApplicationController
  before_action :set_main_case, except: [:finance_index, :confirm_order]
  before_action :set_payment_order, only: [ :edit,
                                            :update,
                                            :destroy,
                                            :submit_current_order,
                                            :confirm_order,
                                            :cancel_order ]

  # 财务管理人员看到的缴费单列表页面
  def finance_index
		data = @current_user.organization.payment_orders.not_confirm
		@payment_orders = initialize_grid(data,
																			order: 'created_at',
																			order_direction: 'desc',
																			per_page: 10,
																			name: 'payment_orders')
	end

	def new
		@payment_order = @main_case.payment_orders.new
		@request_type = :POST
    @path = main_case_payment_orders_path

    if params[:incoming_record_id].blank?
      @payment_order = @main_case.payment_orders.new
    else
      @incoming_record = IncomingRecord.find(params[:incoming_record_id])
      @payment_order = @main_case.payment_orders.new(payer: @incoming_record.pay_person_name,
                                                     total_cost: @incoming_record.amount,
                                                     payment_in_advance: @incoming_record.amount)
    end
	end

	def edit
		@request_type = :PUT
    @path = main_case_payment_order_path
	end

	def update
		respond_to do |format|
      if @payment_order.update(payment_order_params)
        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '编辑缴费单成功'}
        format.json { render :show, status: :ok, location: @payment_order }
      else
        format.html { render :edit }
        format.json { render json: @payment_order.errors, status: :unprocessable_entity }
      end
    end
	end

	def create
		@payment_order = @main_case.payment_orders.new(payment_order_params)
		respond_to do |format|
			if @payment_order.save
				format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '缴费单被成功的创建了！' }
				format.json { render :index, status: :created}
			else
				format.html { render :new }
				format.json { render json: @payment_order.errors, status: :unprocessable_entity }
			end
		end
	end

  def destroy
		@payment_order.destroy
		respond_to do |format|
			format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '缴费单已经被成功的删除了！' }
			format.json { head :no_content }
		end
	end

  # 将当前缴费单的状态改为已提交(未确认)，这样在财务人员那里就可以看到，该缴费单了
  def submit_current_order
		@payment_order.update(order_stage: :not_confirm)

		respond_to do |format|
			format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '当前缴费单已经成功提交了！' }
		end
	end

  # 更新当前缴费单的状态为已确认，这样鉴定人就可以在缴费单里，选择并且创建发票了
  def confirm_order
		respond_to do |format|
			if @payment_order.update(order_stage: :confirm)
				format.html { redirect_to finance_index_main_case_payment_orders_path(-1), notice: '缴费单已经确认！' }
			end
		end
	end

  # 更改当前缴费单状态为作废
  # 作废这个动作只有在缴费单未关联发票前执行，如果已关联了发票则需要提醒用户，删除对应的发票，然后再作废缴费单
  # 当状态为作废时，系统需要取消关联的到账记录，并将该到账记录的状态改为未关联
  def cancel_order
    respond_to do |format|
      if @payment_order.bill.nil?
        if @payment_order.update(order_stage: :cancel)
          format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '缴费单已变为作废状态！' }
        end
      else
        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '当前缴费单已经关联了发票，请删除对应的发票！' }
      end
    end
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
	                                           :mobile_pay,
	                                           :payment_accept_type,
	                                           :check_num,
                                             :incoming_record_id)


		end

    def set_main_case
			@main_case = MainCase.find_by_id(params[:main_case_id])
		end

    def set_payment_order
			@payment_order = PaymentOrder.find(params[:id])
		end
end