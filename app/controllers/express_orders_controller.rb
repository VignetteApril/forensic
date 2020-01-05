class ExpressOrdersController < ApplicationController
  before_action :set_express_order, only: [:show, :edit, :update, :destroy]

  # GET /express_orders
  # GET /express_orders.json
  def index
    data = @current_user.express_orders.all
    @express_orders = initialize_grid(data,
                                      order: 'created_at',
                                      order_direction: 'desc',
                                      per_page: 10,
                                      name: 'express_orders_gird')
  end

  # GET /express_orders/1
  # GET /express_orders/1.json
  def show
  end

  # GET /express_orders/new
  def new
    @express_order = ExpressOrder.new
    @request_type = :POST
    @path = express_orders_path
  end

  # GET /express_orders/1/edit
  def edit
    @request_type = :PUT
    @path = express_order_path
  end

  # POST /express_orders
  # POST /express_orders.json
  def create
    @express_order = @current_user.express_orders.new(express_order_params)

    respond_to do |format|
      if @express_order.save
        if express_order_params[:come_from]
          format.html { redirect_to express_orders_main_case_url(express_order_params[:main_case_id]), notice: '创建发送快递记录成功' }
        else
          format.html { redirect_to express_orders_path, notice: '创建发送快递记录成功' }
        end
        format.json { render :show, status: :created, location: @express_order }
      else
        if express_order_params[:come_from]
          format.html { redirect_to express_orders_main_case_url(express_order_params[:main_case_id]), alert: '快递号已经存在' }
        else
          format.html { render :new }
        end
        format.json { render json: @express_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /express_orders/1
  # PATCH/PUT /express_orders/1.json
  def update
    respond_to do |format|
      if @express_order.update(express_order_params)
        format.html { redirect_to express_orders_path, notice: '修改发送快递记录成功' }
        format.json { render :show, status: :ok, location: @express_order }
      else
        format.html { render :edit }
        format.json { render json: @express_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /express_orders/1
  # DELETE /express_orders/1.json
  def destroy
    @express_order.destroy
    respond_to do |format|
      format.html { redirect_to express_orders_path, notice: '删除发送快递记录成功' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_express_order
      @express_order = ExpressOrder.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def express_order_params
      params.require(:express_order).permit( :receiver,
                                      :reporter,
                                      :receiver_addr,
                                      :receiver_phone,
                                      :company_type,
                                      :order_date,
                                      :content,
                                      :order_num,
                                      :main_case_id,
                                      :come_from)
    end
end
