class RefundOrdersController < ApplicationController
  before_action :set_refund_order, except: [:new, :create, :finance_index]
  before_action :set_main_case, except: [:finance_index]

  def new
    @refund_order = RefundOrder.new
    @request_type = :POST
    @path = main_case_refund_orders_path
  end

  # 财务管理人员看到的缴费单列表页面
  def finance_index
    data = @current_user.organization.refund_orders.not_confirm
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

    respond_to do |format|
      format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '当前退费单已经成功提交了！' }
    end
  end

  # 更新当前退费单的状态为已确认，这样鉴定人就可以在退费单里，选择并且创建发票了
  def confirm_order
    respond_to do |format|
      if @refund_order.update(order_stage: :confirm)
        format.html { redirect_to finance_index_main_case_payment_orders_path(-1), notice: '退费单已经确认！' }
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
                                            :refund_checker_id )
    end

    def set_refund_order
      @refund_order = RefundOrder.find(params[:id])
    end

    def set_main_case
      @main_case = MainCase.find_by_id(params[:main_case_id])
    end

end
