class IncomingRecordsController < ApplicationController
  before_action :set_incoming_record, only: [:show, :edit, :update, :destroy, :claim_record_index , :claim_record]

  # GET /incoming_records
  # GET /incoming_records.json
  def index
    # 当前用户只能看到当前机构的到账记录
    @incoming_records = initialize_grid(@current_user.organization.incoming_records,
                                        per_page: 20,
                                        name: 'incoming_records_grid')
  end

  # GET /incoming_records/1
  # GET /incoming_records/1.json
  def show
  end

  # GET /incoming_records/new
  def new
    @incoming_record = IncomingRecord.new
  end

  # GET /incoming_records/1/edit
  def edit
  end

  # POST /incoming_records
  # POST /incoming_records.json
  def create
    @incoming_record = IncomingRecord.new(incoming_record_params)

    respond_to do |format|
      if @incoming_record.save
        format.html { redirect_to incoming_records_url, notice: '到账记录已经被成功的创建了！' }
        format.json { render :show, status: :created, location: @incoming_record }
      else
        format.html { render :new }
        format.json { render json: @incoming_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incoming_records/1
  # PATCH/PUT /incoming_records/1.json
  def update
    respond_to do |format|
      if @incoming_record.update(incoming_record_params)
        format.html { redirect_to incoming_records_url, notice: '到账记录已经被成功的更新了！' }
        format.json { render :show, status: :ok, location: @incoming_record }
      else
        format.html { render :edit }
        format.json { render json: @incoming_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incoming_records/1
  # DELETE /incoming_records/1.json
  def destroy
    @incoming_record.destroy
    respond_to do |format|
      format.html { redirect_to incoming_records_url, notice: '到账记录已经被成功的删除了！' }
      format.json { head :no_content }
    end
  end

  def claim_record_list
    @incoming_records = initialize_grid(@current_user.organization.incoming_records.unclaimed,
                                        per_page: 20,
                                        name: 'incoming_records_grid')
    respond_to do |format|
      format.html { render :index }
    end
  end

  # 到账记录认领主页面
  # 到账记录的认领只能由鉴定人来完成
  # 因为只能认领到当前用户作为鉴定人的案件中去
  def claim_record_index
    @main_cases = MainCase.ident_user_cases(@current_user)
    redirect_to claim_record_list_incoming_records_url, notice: '只有鉴定人能可以认领到账记录！' and return if @main_cases.empty?
    
    # 默认的会选中第一个案件
    # 所以要初始化第一个案件的缴费单
    @main_case = @main_cases[0]
    if @main_cases.empty?
      @payment_orders = []
    else
      @payment_orders = @main_case.payment_orders.map do |payment_order|
        # 返回的第一个案子的缴费单，应返回还没有关联到账记录的
        [ "付款人：#{payment_order.payer} 付款金额：#{payment_order.total_cost}元", payment_order.id ] if payment_order.incoming_record.nil?
      end.compact
    end
  end

  # 到账记录认领动作提交的到的action
  # PATCH
  def claim_record
    order_id = claim_record_params[:payment_order_id]

    respond_to do |format|
      if order_id.present?
        if PaymentOrder.find(order_id).incoming_record.present?
          format.html { redirect_to claim_record_index_incoming_record_url(@incoming_record), notice: '该缴费单已经认领过到账记录了！' }
        elsif @incoming_record.update(claim_record_params.merge({ status: :claimed }))
          format.html { redirect_to claim_record_list_incoming_records_url, notice: '到账记录已经成功的和缴费单关联！' }
          format.json { render :show, status: :ok, location: @incoming_record }
        else
          format.html { render :claim_record_index }
          format.json { render json: @incoming_record.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to claim_record_index_incoming_record_url(@incoming_record), notice: '请选择一个缴费单进行关联！' }
      end
    end
  end

  # 获取到案件下的所有（已确认的）缴费单
  # POST
  def get_payment_order
    incoming_record = IncomingRecord.find(params[:incoming_record_id])
    main_case = MainCase.find(params[:main_case_id])
    data = main_case.payment_orders.not_submit.map do |payment_order|
      { name: "付款人：#{payment_order.payer} 付款金额：#{payment_order.total_cost}元", id: payment_order.id }
    end

    respond_to do |format|
      format.json { render json: { payment_orders: data,
                                   new_payment_order_url: new_main_case_payment_order_path({main_case_id: main_case, incoming_record_id: incoming_record.id}) } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incoming_record
      @incoming_record = IncomingRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def incoming_record_params
      params.require(:incoming_record).permit(:status,
                                              :pay_account,
                                              :pay_person_name,
                                              :amount,
                                              :pay_date,
                                              :pay_type,
                                              :organization_id,
                                              :check_num)
    end

    def claim_record_params
      params.require(:incoming_record).permit(:payment_order_id)
    end
end
