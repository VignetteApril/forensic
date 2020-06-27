class RefundOrdersController < ApplicationController
  before_action :set_refund_order, except: [:new, :create, :finance_index]
  before_action :set_main_case, except: [:finance_index]
  skip_before_action :can, only: [:print_page]

  def new
    @refund_order = RefundOrder.new
    @request_type = :POST
    @path = main_case_refund_orders_path
  end

  # 财务管理人员看到的缴费单列表页面
  def finance_index
    data = RefundOrder.none
    if !@current_user.organization.nil?
      main_case_ids = @current_user.organization.main_cases.pluck(:id)
      data = RefundOrder.where(main_case_id: main_case_ids)
    end

    @refund_orders = initialize_grid(data,
                                     order: 'created_at',
                                     order_direction: 'desc',
                                     per_page: 10,
                                     name: 'refund_orders')
  end

  def edit
    @request_type = :PUT
    @path = main_case_refund_order_path
  end

  def create
    @refund_order = @main_case.refund_orders.new(refund_order_params)

    respond_to do |format|
      if @refund_order.save
        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '创建退费单成功' }
        format.json { render :show, status: :created, location: @refund_order }
      else
        format.html { render :new }
        format.json { render json: @refund_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @refund_order.update(refund_order_params)
        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '编辑退费单成功'}
        format.json { render :show, status: :ok, location: @refund_order }
      else
        format.html { render :edit }
        format.json { render json: @refund_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @refund_order.destroy
    respond_to do |format|
      format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '删除退费单成功'}
      format.json { head :no_content }
    end
  end

  def submit_current_order
    @refund_order.update(order_stage: :not_confirm)

    # 通知当前机构下的所有财务人员，退费单已经提交
    users = @current_user.organization.users
    users.each do |user|
      # 只通知财务人员
      next if !user.center_finance_user?
      user.notifications.create( channel: :submit_refund_order,
                                 title: "退费单已经提交",
                                 description: "退费单#{@refund_order.id}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}变更为已提交状态",
                                 main_case_id: @refund_order.main_case.id, url: finance_index_main_case_refund_orders_path(-1))
    end

    respond_to do |format|
      format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '当前退费单已经成功提交了！' }
    end
  end

  # 更新当前退费单的状态为已确认，这样鉴定人就可以在退费单里，选择并且创建发票了
  def confirm_order
    respond_to do |format|
      if @refund_order.update(order_stage: :confirm)
        # 发送通知给当前案件的鉴定人
        if !@refund_order.main_case.ident_users.nil?
          users = User.where(id: @refund_order.main_case.ident_users.split(','))

          users.each do |user|
            user.notifications.create( channel: :confirm_refund_order,
                                       title: "退费单已经确认",
                                       description: "退费单#{@refund_order.id}于#{Time.now.strftime('%Y年%m月%d日%H时%M分')}变更为确认状态",
                                       main_case_id: @refund_order.main_case.id, url: payment_order_management_main_case_path(@refund_order.main_case) )
          end
        end

        format.html { redirect_to finance_index_main_case_refund_orders_path(-1), notice: '退费单已经确认！' }
      end
    end
  end

  # 更改当前退费单状态为作废
  def cancel_order
    respond_to do |format|
      if @refund_order.update(order_stage: :cancel)
        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '退费单已变为作废状态！' }
      end
    end
  end

  # 财务人员打印缴费单的页面
  def print_page
    render :layout => false
  end

  private
    def refund_order_params
      params.require(:refund_order).permit( :total_cost,
                                            :appraisal_cost,
                                            :business_cost,
                                            :appear_court_cost,
                                            :investigation_cost,
                                            :other_cost,
                                            :consult_cost,
                                            :refund_cost,
                                            :payee_id,
                                            :refund_dealer_id,
                                            :refund_checker_id,
                                            :refund_reason,
                                            :contract_phone,
                                            :payer,
                                            :payer_contract )
    end

    def set_refund_order
      @refund_order = RefundOrder.find(params[:id])
    end

    def set_main_case
      @main_case = MainCase.find_by_id(params[:main_case_id])
    end

end
