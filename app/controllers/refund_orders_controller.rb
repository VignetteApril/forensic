class RefundOrdersController < ApplicationController
  before_action :set_refund_order, except: [:new, :create]
  before_action :set_main_case

  def new
    @refund_order = RefundOrder.new
    @request_type = :POST
    @path = main_case_refund_orders_path
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
                                            :refund_checker_id
      )

    end
    def set_refund_order
      @refund_order = RefundOrder.find(params[:id])
    end

    def set_main_case
      @main_case = MainCase.find_by_id(params[:main_case_id])
    end

end
