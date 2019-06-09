class MainCasesController < ApplicationController
  before_action :set_main_case, only: [:show, :edit, :update, :destroy, :generate_case_no,
                                       :filing_info, :update_add_material, :update_filing,
                                       :update_reject, :payment, :create_case_doc]
  before_action :set_new_areas, only: [:new, :organization_and_user, :create]
  before_action :set_edit_areas, only: [:edit, :update]
  before_action :set_court_users, only: [:new, :edit, :create]
  before_action :set_anyou_and_case_property, only: [:new, :edit, :create]
  before_action :set_department_matters, only: [:edit, :update]
  before_action :set_case_types, only: [:edit, :update]
  skip_before_action :authorize, only: :payment
  skip_before_action :can, only: :payment

  # GET /main_cases
  # GET /main_cases.json
  def index
    @main_cases = initialize_grid(MainCase, per_page: 20, name: 'main_cases_grid')
  end

  # GET /main_cases/1
  # GET /main_cases/1.json
  def show
    @area_name = Area.find(@main_case.area_id).display_name
  end

  # GET /main_cases/new
  def new
    @main_case = MainCase.new
    @main_case.transfer_docs.build
    @main_case.build_appraised_unit

    # 设置鉴定事项
    set_department_matters

    # 设定案件类型
    set_case_types
  end

  # GET /main_cases/1/edit
  def edit
    @main_case.transfer_docs.build if @main_case.transfer_docs.empty?
  end

  # POST /main_cases
  # POST /main_cases.json
  def create
    @main_case = MainCase.new(main_case_params)
    @main_case.area_id = _area_id(main_case_params[:province_id],
                                  main_case_params[:city_id],
                                  main_case_params[:district_id])
    respond_to do |format|
      if @main_case.save
        format.html { redirect_to main_cases_url, notice: 'Main case was successfully created.' }
        format.json { render :show, status: :created, location: @main_case }
      else
        format.html { render :new }
        # format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /main_cases/1
  # PATCH/PUT /main_cases/1.json
  def update
    @main_case.area_id = _area_id(main_case_params[:province_id],
                                  main_case_params[:city_id],
                                  main_case_params[:district_id])

    respond_to do |format|
      if @main_case.update(main_case_params)
        format.html { redirect_to main_cases_url, notice: 'Main case was successfully updated.' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { render :edit }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /main_cases/1
  # DELETE /main_cases/1.json
  def destroy
    @main_case.destroy
    respond_to do |format|
      format.html { redirect_to main_cases_url, notice: 'Main case was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def organization_and_user
    user = User.find(params[:user_id])

    case user.organization.area.area_type.to_sym
    when :district
      @current_province = user.organization.area.root
      @current_city = user.organization.area.parent
      @current_district = user.organization.area
      @cites = @current_province.children
      @districts = @current_city.children
    when :city
      @current_province = user.organization.area.root
      @current_city = user.organization.area
      @current_district = []
      @cites = @current_province.children
      @districts = []
    when :province
      @current_province = user.organization.area
      @current_city = []
      @current_district = []
      @cites = []
      @districts = []
    end

    @organization_name = user.organization.name
    @organization_phone = user.organization.phone
    @organization_addr = user.organization.addr
    @user_name = user.name

    rs_current_province = { text: @current_province.name, id: @current_province.id }
    rs_current_city = { text: @current_city.name, id: @current_city.id }
    rs_current_district = { text: @current_district.name, id: @current_district.id }
    rs_provinces = @provinces.map { |province| { text: province.name, id: province.id } }
    rs_cities = @cites.map { |city| { text: city.name, id: city.id } }
    rs_districts = @districts.map { |district| { text: district.name, id: district.id } }

    respond_to do |format|
      format.json { render json: { current_province: rs_current_province,
                                   current_district: rs_current_district,
                                   current_city: rs_current_city,
                                   cities: rs_cities,
                                   districts: rs_districts,
                                   provinces: rs_provinces,
                                   organization_name: @organization_name,
                                   organization_addr: @organization_addr,
                                   organization_phone: @organization_phone,
                                   user_name: @user_name,
                                   user_id: user.id } }
    end
  end

  def matter_demands_and_case_types
    department = Department.find(params[:department_id])
    if department.matter
      matters = department.matter.split(',').map { |matter| { text: matter, id: matter } }
    else
      matters = []
    end

    if department.case_types
      case_types = department.case_types.split(',').map { |case_type| { text: case_type , id: case_type } }
    else
      case_types = []
    end

    respond_to do |format|
      format.json { render json: { matters: matters, case_types: case_types } }
    end
  end

  def generate_case_no
    @main_case.set_case_no

    redirect_to edit_main_case_url(@main_case)
  end

  # 案件审查主页面
  def filing_info
    current_org = @main_case.department.organization
    @material_cycles =  current_org.material_cycles.map(&:day)
    @identification_cycles = current_org.identification_cycles.map(&:day)
    @users = @main_case.department.user_array.map { |user| [user.name, user.id] }
    @select_ident_users = @main_case.ident_users.nil? ? [] : current_org.users.where(id: @main_case.ident_users.split(',')).map(&:id)
  end

  # 立案信息中补充材料表单提交的位置
  def update_add_material
    respond_to do |format|
      if @main_case.update(material_cycle:  params[:main_case][:material_cycle])
        @main_case.turn_add_material
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '案件已经进入补充材料阶段' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '保存出错，请重新输入相关信息！' }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # 案件审查中立案信息表达提交的位置
  # 案件这变为立案的状态
  # 并设置受理日期
  def update_filing
    respond_to do |format|
      if @main_case.update(identification_cycle: params[:main_case][:identification_cycle],
                           pass_user: params[:main_case][:pass_user],
                           sign_user: params[:main_case][:sign_user],
                           ident_users: params[:main_case][:ident_users].join(','),
                           payer: params[:main_case][:payer],
                           payer_phone: params[:main_case][:payer_phone],
                           case_stage: :filed,
                           acceptance_date: Date.today)
        @main_case.turn_filed
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '案件已经进入立案阶段' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '保存出错，请重新输入相关信息！' }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # 案件审查中推案提交的位置
  def update_reject
    respond_to do |format|
      if @main_case.turn_rejected
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '案件已退案！' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '保存出错，请重新输入相关信息！' }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # 打开条码的modal的方法，因为传递图片的地址进去
  # respond to only js
  def open_barcode_image
    if params[:transfer_doc_id]
      transfer_doc = TransferDoc.find(params[:transfer_doc_id])
      @barcode_image = transfer_doc.barcode_image
    elsif params[:main_case_id]
      main_case = MainCase.find(params[:main_case_id])
      @barcode_image = main_case.barcode_image
    end

    respond_to do |format|
      format.js
    end
  end

  # TODO: 静态的付款页面，里面包含机构的【收款人名称】、【开户行】、【银行账号】
  # TODO: 该页面可能会被费用管理部分的付款页面取代
  # 付款页面
  def payment
    @organization = @main_case.department.organization

    render layout: false
  end

  # 在立案信息的立案表单部分，用户点击【添加文件】按钮，系统弹出模态框人用户填写相关信息，然后点击确认创建
  # 创建完毕后使用ajax的方式刷新当前页面显示文档的部分
  def create_case_doc
    case_doc = @main_case.case_docs.new(case_doc_params.merge({ case_stage: :filed }))

    respond_to do |format|
      if case_doc.save
        format.js
      else
        flash[:warning] = "文件上传失败，请重新上传！"
        format.js { render 'layouts/display_flash' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_main_case
      @main_case = MainCase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def main_case_params
      params.require(:main_case).permit(:serial_no,
                                        :case_no,
                                        :user_id,
                                        :accept_date,
                                        :case_stage,
                                        :case_close_date,
                                        :case_type,
                                        :province_id,
                                        :city_id,
                                        :district_id,
                                        :organization_name,
                                        :user_name,
                                        :organization_phone,
                                        :organization_addr,
                                        :department_id,
                                        :anyou,
                                        :case_property,
                                        :commission_date,
                                        { matter: [] },
                                        :matter_demand,
                                        :base_info,
                                        transfer_docs_attributes: [:id,
                                                                   :name,
                                                                   :doc_type,
                                                                   :num,
                                                                   :unit,
                                                                   :traits,
                                                                   :status,
                                                                   :receive_date,
                                                                   :barcode,
                                                                   :attachment,
                                                                   :_destroy],
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

    def case_doc_params
      params.require(:department_doc).permit(:name,
                                             :doc_code,
                                             :check_archived,
                                             :check_archived_no,
                                             :attachment)
    end

    def set_new_areas
      @provinces = Area.roots
      @cities = @provinces.first.children
      @districts = []
    end

    def set_edit_areas
      province_id = @main_case.province_id
      city_id = @main_case.city_id
      @provinces = Area.roots
      @cities = province_id.nil? ? @provinces.first.children : Area.find(province_id).children
      @districts = city_id.nil? ? [] : Area.find(city_id).children
    end

    def set_court_users
      @users = User.where(user_type: :court_user).map { |user| [ user.name, user.id ] }
    end

    def set_anyou_and_case_property
      @anyou = ANYOU.map { |anyou| [ anyou, anyou ] }
      @case_property = CASE_PROPERTY.map{ |case_property| [case_property, case_property] }
    end

    def set_department_matters
      if @main_case.matter.blank?
        @department_matters = []
        @selected_matters = []
      else
        @department_matters = JSON.parse(@main_case.matter).map { |matter| [matter, matter] }
        @selected_matters = @department_matters.nil? ? [] : @department_matters.map(&:first)
      end
    end

    def set_case_types
      case_type = @main_case.case_type
      @selected_case_type = [case_type, case_type]
      @collection_case_types = []
      if @main_case.department && !@main_case.department.case_types.blank?
        @collection_case_types = @main_case.department.case_types.split(',').map { |case_type| [case_type, case_type] }
      end
    end
end
