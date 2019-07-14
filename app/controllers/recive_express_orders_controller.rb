class ReciveExpressOrdersController < ApplicationController
  before_action :set_recive_express_order, only: [:show, :edit, :update, :destroy]

  # GET /recive_express_orders
  # GET /recive_express_orders.json
  def index
    data = @current_user.recive_express_orders.all
    @recive_express_orders = initialize_grid(data,
                                      order: 'created_at',
                                      order_direction: 'desc',
                                      per_page: 10,
                                      name: 'recive_express_orders_gird')
  end

  # GET /recive_express_orders/1
  # GET /recive_express_orders/1.json
  def show
  end

  # GET /recive_express_orders/new
  def new
    @recive_express_order = ReciveExpressOrder.new
    @request_type = :POST
    @path = recive_express_orders_path
  end

  # GET /recive_express_orders/1/edit
  def edit
    @request_type = :PUT
    @path = recive_express_order_path
  end

  # POST /recive_express_orders
  # POST /recive_express_orders.json
  def create
    @recive_express_order = @current_user.recive_express_orders.new(recive_express_order_params)

    respond_to do |format|
      if @recive_express_order.save
        format.html { redirect_to recive_express_orders_path, notice: '创建收到快递记录成功' }
        format.json { render :show, status: :created, location: @recive_express_order }
      else
        format.html { render :new }
        format.json { render json: @recive_express_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recive_express_orders/1
  # PATCH/PUT /recive_express_orders/1.json
  def update
    respond_to do |format|
      if @recive_express_order.update(recive_express_order_params)
        format.html { redirect_to recive_express_orders_path, notice: '修改收到快递记录成功' }
        format.json { render :show, status: :ok, location: @recive_express_order }
      else
        format.html { render :edit }
        format.json { render json: @recive_express_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recive_express_orders/1
  # DELETE /recive_express_orders/1.json
  def destroy
    @recive_express_order.destroy
    respond_to do |format|
      format.html { redirect_to recive_express_orders_url, notice: '删除收到快递记录成功' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recive_express_order
      @recive_express_order = ReciveExpressOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recive_express_order_params
        params.require(:recive_express_order).permit( :sender,
                                  :company_type,
                                  :order_date,
                                  :content,
                                  :order_num,
                                  :main_case_id )
    end
end