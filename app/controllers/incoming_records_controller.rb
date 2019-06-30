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


  # 到账记录认领主页面
  def claim_record_index
    @main_cases = @current_user.organization.main_cases
  end

  # 到账记录认领动作提交的到的action
  # PATCH
  def claim_record
    respond_to do |format|
      if @incoming_record.update(claim_record_params.merge({ status: :claimed }))
        format.html { redirect_to incoming_records_url, notice: '到账记录已经成功的和缴费单关联！' }
        format.json { render :show, status: :ok, location: @incoming_record }
      else
        format.html { render :edit }
        format.json { render json: @incoming_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # 获取到案件下的所有（已确认的）缴费单
  # POST
  def get_payment_order
    main_case = MainCase.find(params[:id])
    data = main_case.payment_orders.map do |payment_order|
      { text: payment_order.payer, value: payment_order.id }
    end

    respond_to do |format|
      format.json { render json: { payment_orders: data } }
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
                                              :organization_id)
    end

    def claim_record_params
      params.require(:incoming_record).permit(:payment_order_id)
    end
end
