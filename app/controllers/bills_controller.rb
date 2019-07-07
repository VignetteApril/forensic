# 发票控制器
class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy, :to_billed, :to_taked_away]
  before_action :set_main_case, except: [:finance_index, :to_billed, :to_taked_away]
  before_action :guard_edit_destroy, only: [:edit, :destroy]

  # GET /bills
  # GET /bills.json
  def index
    @bills = Bill.all
  end

  def finance_index
    data = @current_user.organization.bills
    @bills = initialize_grid(data,
                             order: 'created_at',
                             order_direction: 'desc',
                             per_page: 10,
                             name: 'bills')
  end

  # GET /bills/1
  # GET /bills/1.json
  def show
  end

  # GET /bills/new
  def new
    @bill = Bill.new
  end

  # GET /bills/1/edit
  def edit
  end

  # POST /bills
  # POST /bills.json
  def create
    if params[:payment_orders].nil? || params[:payment_orders][:selected].empty?
      redirect_to payment_order_management_main_case_path(@main_case), notice: '请勾选缴费单！' and return
    end
    @bill = @main_case.bills.new(bill_params)
    payment_order_ids = params[:payment_orders][:selected]

    respond_to do |format|
      if @bill.save
        payment_orders = PaymentOrder.where(id: payment_order_ids)
        payment_orders.update_all(bill_id: @bill.id)

        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '发票已经创建成功了！' }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { render :new }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bills/1
  # PATCH/PUT /bills/1.json
  def update
    respond_to do |format|
      if @bill.update(bill_params)
        format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '发票已经更新成功了！' }
        format.json { render :show, status: :ok, location: @bill }
      else
        format.html { render :edit }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    @bill.destroy
    respond_to do |format|
      format.html { redirect_to payment_order_management_main_case_path(@main_case), notice: '发票已经成功的被摧毁了！' }
      format.json { head :no_content }
    end
  end

  # 更新发票状态为已开
  def to_billed
    respond_to do |format|
      if @bill.update(bill_stage: :billed)
        format.html { redirect_to finance_index_main_case_bills_path(-1), notice: '发票已经变更为已开状态' }
      end
    end
  end

  # 更细发票状态为已领走
  def to_taked_away
    respond_to do |format|
      if @bill.update(bill_stage: :taked_away)
        format.html { redirect_to finance_index_main_case_bills_path(-1), notice: '发票已经变更为已领走状态' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill
      @bill = Bill.find(params[:id])
    end

    def set_main_case
      @main_case = MainCase.find_by_id(params[:main_case_id])
    end

    # Never trust parameters from the scary intern\et, only allow the white list through.
    def bill_params
      params.require(:bill).permit(:bill_type, :organization, :code, :bank, :address, :amount)
    end

    # 当发票状态变为已开/已领走后就不能再edit和destroy
    def guard_edit_destroy
      redirect_to payment_order_management_main_case_path(@main_case), notice: '发票已开或已领走！' if @bill.billed? || @bill.taked_away?
    end
end
