class PaymentOrdersController < ApplicationController
  before_action :set_main_case, except: [:finance_index, :confirm_order]
  before_action :set_payment_order, only: [ :edit,
                                            :update,
                                            :destroy,
                                            :submit_current_order,
                                            :confirm_order,
                                            :cancel_order,
                                            :finance_show,
                                            :print_page ]

  # 财务管理人员看到的缴费单列表页面
  # 能够看到当前机构下的所有缴费的提交清单
  def finance_index
		data = PaymentOrder.none
    if !@current_user.organization.nil?
      main_case_ids = @current_user.organization.main_cases.pluck(:id)
      data = PaymentOrder.where(main_case_id: main_case_ids)
		end

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
			new_params = { payer: @incoming_record.pay_person_name,
										 total_cost: @incoming_record.amount,
										 payment_in_advance: @incoming_record.amount }

			case @incoming_record.pay_type.to_sym
			when :check
				new_params.merge!({ check_pay: @incoming_record.amount, check_num: @incoming_record.check_num })
			when :cash
				new_params.merge!({ cash_pay: @incoming_record.amount })
			when :remit
				new_params.merge!({ remit_pay: @incoming_record.amount, payment_date: @incoming_record.pay_date, payment_people: @incoming_record.pay_person_name })
			when :wechat
				new_params.merge!({ mobile_pay: @incoming_record.amount })
			when :card
				new_params.merge!({ card_pay: @incoming_record.amount })
			end

			@claim_user_id = params[:claim_user_id]

      @payment_order = @main_case.payment_orders.new(new_params)
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
  # 当缴费的状态变为已提交时，需要通知当前科室下的所有财务人员
  def submit_current_order
		@payment_order.update(order_stage: :not_confirm)
    # 拿到当前机构下的所有user
    # 然后通知当前机构下的财务人员，某个缴费单已经提交了
    users = @current_user.organization.users
    users.each do |user|
      # 只通知财务人员
      next if !user.center_finance_user?
      user.notifications.create( channel: :submit_payment_order,
                                 title: "缴费单已经提交",
                                 description: "缴费单#{@payment_order.id}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}变更为已提交状态",
                                 main_case_id: @payment_order.main_case.id, url: finance_index_main_case_payment_orders_path(-1))
    end

		respond_to do |format|
			format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '当前缴费单已经成功提交了！' }
		end
	end

  # 更新当前缴费单的状态为已确认，这样鉴定人就可以在缴费单里，选择并且创建发票了
  def confirm_order
		respond_to do |format|
			if @payment_order.update(order_stage: :confirm)
        # 发送通知给当前案件的鉴定人
        if !@payment_order.main_case.ident_users.nil?
          users = User.where(id: @payment_order.main_case.ident_users.split(','))

          users.each do |user|
            user.notifications.create( channel: :confirm_payment_order,
                                       title: "缴费单已经确认",
                                       description: "缴费单#{@payment_order.id}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}变更为确认状态",
                                       main_case_id: @payment_order.main_case.id, url: payment_order_management_main_case_path(@payment_order.main_case) )
          end
        end

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

  # 财务人员查看缴费单详情页
  def finance_show
    @main_case = @payment_order.main_case
  end

  # 财务人员打印缴费单的页面
  def print_page
    render :layout => false
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
                                             :incoming_record_id,
                                             :claim_user_id)


		end

    def set_main_case
			@main_case = MainCase.find_by_id(params[:main_case_id])
		end

    def set_payment_order
			@payment_order = PaymentOrder.find(params[:id])
		end
end