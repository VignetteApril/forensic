class EntrustOrdersController < ApplicationController
  before_action :set_entrust_order, only: [:show, :edit, :update, :destroy]
  before_action :set_anyou_and_case_property, only: [:new, :edit, :update, :create]
  before_action :center_collection, only: [:new, :edit, :update, :create]

  # GET /entrust_orders
  # GET /entrust_orders.json
  # 委托人查看自己的委托单页面
  def index
    @entrust_orders = initialize_grid(@current_user.entrust_orders.includes(:organization),
                                      name: 'entrust_orders',
                                      enable_export_to_csv: true,
                                      csv_field_separator: ';',
                                      csv_file_name: 'entrust_orders_csv',
                                      per_page: 20)
    export_grid_if_requested
  end

  # 鉴定中心查看委托单功能
  # 查看用户所在的机构的所有委托单
  def org_orders
    @entrust_orders = initialize_grid( @current_user.organization.entrust_orders.includes(:organization),
                                      name: 'entrust_orders',
                                      per_page: 20)
    render :index
  end

  # 鉴定中心查看委托单功能
  # 查看用户所在机构下所有未认领的委托单
  def org_orders_unclaimed
    @entrust_orders = initialize_grid( @current_user.organization.entrust_orders.unclaimed.includes(:organization),
                                       name: 'entrust_orders',
                                       per_page: 20)
    render :index
  end

  # GET /entrust_orders/1
  # GET /entrust_orders/1.json
  def show
  end

  # GET /entrust_orders/new
  def new
    @entrust_order = EntrustOrder.new
    @entrust_order.build_appraised_unit
  end

  # GET /entrust_orders/1/edit
  def edit
  end

  # POST /entrust_orders
  # POST /entrust_orders.json
  def create
    @entrust_order = EntrustOrder.new(entrust_order_params)

    respond_to do |format|
      if @entrust_order.save
        format.html { redirect_to entrust_orders_url, notice: '委托单已经被成功的创建了！' }
        format.json { render :show, status: :created, location: @entrust_order }
      else
        format.html { render :new }
        format.json { render json: @entrust_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entrust_orders/1
  # PATCH/PUT /entrust_orders/1.json
  def update
    respond_to do |format|
      if @entrust_order.update(entrust_order_params)
        format.html { redirect_to entrust_orders_url, notice: '委托单已经被成功的更新了！' }
        format.json { render :show, status: :ok, location: @entrust_order }
      else
        format.html { render :edit }
        format.json { render json: @entrust_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entrust_orders/1
  # DELETE /entrust_orders/1.json
  def destroy
    @entrust_order.destroy
    respond_to do |format|
      format.html { redirect_to entrust_orders_url, notice: '委托单已经被成功的删除了！' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entrust_order
      @entrust_order = EntrustOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entrust_order_params
      params.require(:entrust_order).permit(:main_case_id,
                                            :user_id,
                                            :case_property,
                                            :matter_demand,
                                            :base_info,
                                            :anyou,
                                            :organization_id,
                                            appraised_unit_attributes: [:id,
                                                                        :unit_type,
                                                                        :name,
                                                                        :addr,
                                                                        :gender,
                                                                        :birthday,
                                                                        :id_type,
                                                                        :id_num,
                                                                        :_destroy])
    end

    def set_anyou_and_case_property
      @anyou = ANYOU.map { |anyou| [ anyou, anyou ] }
      @case_property = CASE_PROPERTY.map{ |case_property| [case_property, case_property] }
    end

    def center_collection
      @center_collection = Organization.center
    end
end
