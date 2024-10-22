require 'ems'

class MainCasesController < ApplicationController
  before_action :forbid_admin_user, except: [:payment, :express_route]
  before_action :set_main_case, only: [:show, :edit, :update, :destroy, :generate_case_no,
                                       :filing_info, :update_add_material, :update_filing,
                                       :update_reject, :payment, :create_case_doc, :payment_order_management,
                                       :save_payment_order, :case_executing, :update_case_stage, :update_financial_stage,
                                       :display_dynamic_file_modal, :closing_case, :case_memos, :create_case_memo,
                                       :case_process_records, :show_payment_order, :express_orders]
  before_action :set_new_areas, only: [:new, :organization_and_user, :create, :new_with_entrust_order, :finance_check_cases]
  before_action :set_edit_areas, only: [:edit, :update, :express_orders]
  before_action :set_court_users, only: [:new, :edit, :create]
  before_action :set_anyou_and_case_property, only: [:new, :edit, :create]
  before_action :set_department_matters, only: [:edit, :update]
  before_action :set_case_types, only: [:edit, :update]
  before_action :set_entrust_orders, only: [ :edit, :update, :new, :create ]
  before_action :set_departments, only: [:new, :edit, :create, :update, :new_with_entrust_order]
  before_action :check_department, only: [:department_closed_cases, :department_cases, :pending_cases]
  skip_before_action :authorize, only: [:payment, :express_route]
  skip_before_action :can, only: [:payment, :express_route, :create_organization_and_user, :organization_and_user]
  skip_before_action :verify_authenticity_token, only: :express_route

  # 我的案件页面
  # GET /main_cases
  # GET /main_cases.json
  # admin用户可以看到全部case的信息
  # 没有机构的用户调到首页，告诉用户去设置对应的机构
  # 通过用户的机构类型看如果是法院的话，就说明该用户为委托人，委托人的话只能看跟自己相关的case
  # 除去以上所有情况，剩下的用户都为鉴定中心的用，鉴定中心的用户在该action里
  # 鉴定中心人员只能看到自己作为鉴定人的案件
  def index
    if @current_user.admin?
      data = MainCase
    elsif @current_user.organization.nil?
      redirect_to acceptable_url('sessions', 'index'), notice: '请您关联对应的机构'
    elsif @current_user.client_entrust_user?
      data = MainCase.where(wtr_id: @current_user.id)
    else
      current_org_cases = @current_user.organization.main_cases
      case_ids = current_org_cases.map { |main_case| main_case.id if main_case.ident_users.present? && main_case.ident_users.split(',').include?(@current_user.id.to_s) }
      data = MainCase.where(id: case_ids)
    end

    data = set_filter_instance(data, @current_user)

    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')
    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
  end

  def my_closed_cases
    current_org_cases = @current_user.organization.main_cases
    data = MainCase.where(id: current_org_cases, case_stage: :close)
    data = set_filter_instance(data, @current_user)

    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')
    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
  end

  def department_closed_cases
    data = MainCase.where(department_id: @current_user.departments.split(','), case_stage: :close)
    data = set_filter_instance(data, @current_user)
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')

    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
  end

  # 本科室案件页面
  # 本页面不为管理员和委托人这两种角色设计，请不要在这两个角色下添加该功能
  # 委托人没有这个页面
  # 鉴定中心的人所在科室下的所有案件
  # 针对本中心的人没有权限
  def department_cases
    data = MainCase.where(department_id: @current_user.departments.split(','))
    data = set_filter_instance(data, @current_user)
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')
    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')

    render :index
  end

  # 本中心案件页面
  # 本页面不为管理员和委托人这两种角色设计，请不要在这两个角色下添加该功能
  # 委托人没有这个页面；【鉴定中心管理员】和【鉴定中心主任】有这个菜单（由于权限是灵活的只要给正确的角色配正确的权限即可）
  def center_cases
    data = @current_user.organization.main_cases
    data = set_filter_instance(data, @current_user)
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')

    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
  end

  # 委托人查看案件
  def wtr_cases
    data = MainCase.where(wtr_id: @current_user.id)
    data = set_filter_instance(data, @current_user)
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')
    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')

    render :index
  end

  # 已付款待立案页面
  # 通过财务状态：【已付款】和案件状态：【待立案】，筛选本中心的所有案件
  # 本页面属于角色为财务人员
  def filed_unpaid_cases
    current_org_cases = @current_user.organization.main_cases
    data = current_org_cases.where(case_stage: :filed, financial_stage: :unpaid)
    data = set_filter_instance(data, @current_user)
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')
    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
  end

  # 财务人员查看所有案件的
  def finance_check_cases
    data = @current_user.organization.main_cases

    if params["main_cases_grid"] && params["main_cases_grid"]["export"].nil?
      province_id = params["main_cases_grid"]["f"]["province_id"][0] if params["main_cases_grid"]["f"]["province_id"]
      city_id = params["main_cases_grid"]["f"]["city_id"][0] if params["main_cases_grid"]["f"]["city_id"]

      department_name = params["main_cases_grid"]["f"]["departments.name"][0] if params["main_cases_grid"]["f"]["departments.name"]
      ident_users = params["main_cases_grid"]["f"]["ident_users"][0] if params["main_cases_grid"]["f"]["ident_users"]
      pass_user = params["main_cases_grid"]["f"]["pass_user"][0] if params["main_cases_grid"]["f"]["pass_user"]
      matter = params["main_cases_grid"]["f"]["matter"][0] if params["main_cases_grid"]["f"]["matter"]

      # 如果有params["main_cases_grid"]["f"] payment_method 的key 则用自定义的搜索条件
      @payment_method = params["main_cases_grid"]["f"].delete("payment_method")[0] if params["main_cases_grid"]["f"]["payment_method"]
      case @payment_method
      when '现金收款'
        data = data.select { |main_case| main_case.payment_orders.where.not(cash_pay: nil).length > 0 }
      when '银行汇款'
        data = data.select { |main_case| main_case.payment_orders.where.not(remit_pay: nil).length > 0 }
      when '其他'
        data = data.select do |main_case|
          main_case.payment_orders.where.not(card_pay: nil).length > 0 || \
          main_case.payment_orders.where.not(mobile_pay: nil).length > 0 || \
          main_case.payment_orders.where.not(check_pay: nil).length > 0
        end
      end

      pay_date = params["main_cases_grid"]["f"].delete("pay_date") if params["main_cases_grid"]["f"]["pay_date"]
      if pay_date
        pay_start_date = Date.new(*pay_date["fr"].split('-').map(&:to_i)).beginning_of_day
        pay_end_date = Date.new(*pay_date["to"].split('-').map(&:to_i)).end_of_day
        data = data.select { |main_case| main_case.payment_orders.where(created_at: pay_start_date..pay_end_date).length > 0 }
        @pay_date_fr = pay_date["fr"]
        @pay_date_to = pay_date["to"]
      end

      @bill_status = params["main_cases_grid"]["f"].delete("bill_status")[0] if params["main_cases_grid"]["f"]["bill_status"]
      if @bill_status
        case @bill_status
        when '已开'
          data = data.select { |main_case| main_case.bills.billed.length > 0 }
        when '未开'
          data = data.select { |main_case| main_case.bills.unBilled.length > 0 }
        end
      end

      @search_type = params["main_cases_grid"]["f"].delete("search_type")[0] if params["main_cases_grid"]["f"]["search_type"]
      if @search_type
        search_date = params["main_cases_grid"]["f"].delete("search_date") if params["main_cases_grid"]["f"]["search_date"]
        if search_date
          search_start_date = Date.new(*search_date["fr"].split('-').map(&:to_i)).beginning_of_day
          search_end_date = Date.new(*search_date["to"].split('-').map(&:to_i)).end_of_day
          case @search_type
          when '受理'
            data = data.where(commission_date: search_start_date..search_end_date)
          when '立案'
            data = data.where(acceptance_date: search_start_date..search_end_date)
          when '结案'
            data = data.where(close_case_date: search_start_date..search_end_date)
          end

          @search_date_fr = search_date["fr"]
          @search_date_to = search_date["to"]
        end
      end
    end

    @provinces = Area.roots.map { |province| [province.name, province.id] }
    @cities = province_id.nil? ? [] : Area.find(province_id).children.map { |item| [item.name, item.id] }
    @districts = city_id.nil? ? [] : Area.find(city_id).children.map { |item| [item.name, item.id] }
    organizaton = @current_user.organization
    @department = organizaton.departments.where(name: department_name).first
    if @department && @department.matter
      @matters = @department.matter.split(',').map { |matter| [ matter, matter ] }
    else
      @matters = []
    end

    users = @department.user_array if @department
    if @department && !users.empty?
      @users = users.map { |user| [ user.name, user.id ] }
    else
      @users = []
    end

    data = @current_user.organization.main_cases.where(id: data.map(&:id))
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'finance_main_cases_grid')
    export_grid_if_requested('finance_main_cases_grid' => 'finance_main_cases_grid')
  end

  # 案件状态为【申请归档】的案件列表页面
  # 该页面的权限属于档案管理员
  def apply_filing_cases
    current_org_cases = @current_user.organization.main_cases
    data = current_org_cases.where(case_stage: :apply_filing)
    data = set_filter_instance(data, @current_user)

    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')
    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
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
    @case_memo = @main_case.case_memos.new
  end

  # POST /main_cases
  # POST /main_cases.json
  def create
    @main_case = MainCase.new(main_case_params)
    @main_case.area_id = _area_id(main_case_params[:province_id],
                                  main_case_params[:city_id],
                                  main_case_params[:district_id])
    attach_data_str(@main_case, main_case_params[:data_str]) if main_case_params[:data_str].present?

    respond_to do |format|
      # 案件创建后跳转到待立案的案件
      if @main_case.save
        # 使案件进入待立案的状态
        @main_case.turn_pending!
        format.html { redirect_to pending_cases_main_cases_path, notice: '案件已经成功创建了！' }
        format.json { render :show, status: :created, location: @main_case }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /main_cases/1
  # PATCH/PUT /main_cases/1.json
  def update
    @main_case.area_id = _area_id(main_case_params[:province_id],
                                  main_case_params[:city_id],
                                  main_case_params[:district_id])
    attach_data_str(@main_case, main_case_params[:data_str]) if main_case_params[:data_str].present?

    respond_to do |format|
      if @main_case.update(main_case_params)
        if main_case_params[:appraisal_opinion].nil?
          format.html { redirect_to edit_main_case_url(@main_case), notice: '案件已经成功更新了！' }
        else
          format.html { redirect_to case_executing_main_case_url(@main_case), notice: '案件已经成功更新了！' }
        end
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
      format.html { redirect_to main_cases_url, notice: '案件已经成功的删除了！' }
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
      @current_district = Area.new
      @cites = @current_province.children
      @districts = []
    when :province
      @current_province = user.organization.area
      @current_city = Area.new
      @current_district = Area.new
      @cites = []
      @districts = []
    end

    @organization_name = user.organization.name
    @wtr_phone = user.mobile_phone
    @organization_addr = user.address
    @user_name = user.name

    rs_current_province = { name: @current_province.name, id: @current_province.id }
    rs_current_city = { name: @current_city.name, id: @current_city.id }
    rs_current_district = { name: @current_district.name, id: @current_district.id }
    rs_provinces = @provinces.map { |province| { name: province.name, id: province.id } }
    rs_cities = @cites.map { |city| { name: city.name, id: city.id } }
    rs_districts = @districts.map { |district| { name: district.name, id: district.id } }

    respond_to do |format|
      format.json { render json: { current_province: rs_current_province,
                                   current_district: rs_current_district,
                                   current_city: rs_current_city,
                                   cities: rs_cities,
                                   districts: rs_districts,
                                   provinces: rs_provinces,
                                   organization_name: @organization_name,
                                   organization_addr: @organization_addr,
                                   wtr_phone: @wtr_phone,
                                   user_name: @user_name,
                                   user_id: user.id } }
    end
  end

  def matter_demands_and_case_types
    department = Department.find(params[:department_id])
    if department.matter
      matters = department.matter.split(',').map { |matter| { name: matter, id: matter } }
    else
      matters = []
    end

    if department.case_types
      case_types = department.case_types.split(',').map { |case_type| { name: case_type , id: case_type } }
    else
      case_types = []
    end

    respond_to do |format|
      format.json { render json: { matters: matters, case_types: case_types } }
    end
  end

  def generate_case_no
    current_action = params[:current_action]
    @main_case.set_case_no

    case current_action
    when 'filing_info'
      redirect_url = filing_info_main_case_url(@main_case)
    when 'payment_order_management'
      redirect_url = payment_order_management_main_case_url(@main_case)
    when 'case_executing'
      redirect_url = case_executing_main_case_url(@main_case)
    when 'closing_case'
      redirect_url = closing_case_main_case_url(@main_case)
    when 'case_memos'
      redirect_url = case_memos_main_case_url(@main_case)
    when 'express_orders'
      redirect_url = express_orders_main_case_url(@main_case)
    when 'edit'
      redirect_url = edit_main_case_url(@main_case)
    end

    redirect_to redirect_url, notice: '案件号已经生成！'
  end

  # 案件审查主页面
  def filing_info
    current_org = @main_case.department.organization
    @material_cycles =  current_org.material_cycles.map(&:day)
    @identification_cycles = current_org.identification_cycles.map(&:day)
    @users = @main_case.department.user_array.map { |user| [user.name, user.id] }
    @select_ident_users = []
    @ident_users = ''
    if @main_case.ident_users
      user_ids = @main_case.ident_users.split(',')
      users = User.where(id: user_ids).pluck(:id, :name).to_h
      user_ids.each_with_index do |id, index|
        @ident_users << "第#{index + 1}鉴定人：#{users[id.to_i]}  "
        @select_ident_users << id.to_i
      end
    end
  end

  # 立案信息中补充材料表单提交的位置
  # method patch
  # 参数 :material_cycle 补充材料周期
  def update_add_material
    respond_to do |format|
      if @main_case.update(material_cycle:  params[:main_case][:material_cycle])
        @main_case.turn_add_material!
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
  # method patch
  def update_filing
    ident_users = params[:main_case][:ident_users].blank? ? "" : params[:main_case][:ident_users].join(',')
    respond_to do |format|
      if @main_case.update(identification_cycle: params[:main_case][:identification_cycle],
                           pass_user: params[:main_case][:pass_user],
                           assist_ident_user: params[:main_case][:assist_ident_user],
                           sign_user: params[:main_case][:sign_user],
                           ident_users: ident_users,
                           payer: params[:main_case][:payer],
                           payer_phone: params[:main_case][:payer_phone],
                           amount: params[:main_case][:amount],
                           case_stage: :filed,
                           acceptance_date: Time.now)
        @main_case.turn_filed!
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '案件已经进入立案阶段' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '保存出错，请重新输入相关信息！' }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # 案件审查中推案提交的位置
  # method patch
  def update_reject
    respond_to do |format|
      if @main_case.turn_rejected!
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '案件已退案！' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { redirect_to filing_info_main_case_url(@main_case), notice: '保存出错，请重新输入相关信息！' }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # 打开条码的modal的方法，传递图片的地址进去
  # respond to only js
  def open_barcode_image
    if params[:transfer_doc_id]
      @transfer_doc = TransferDoc.find(params[:transfer_doc_id])
      @main_case = @transfer_doc.main_case
      @barcode_image = @transfer_doc.barcode_image
    elsif params[:main_case_id]
      @main_case = MainCase.find(params[:main_case_id])
      @barcode_image = @main_case.barcode_image
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

  # 用户点击【添加文件】按钮，系统弹出模态框人用户填写相关信息，然后点击确认创建
  # 创建完毕后使用ajax的方式刷新当前页面显示文档的部分
  def create_case_doc
    @partial_name = params[:department_doc][:partial_name]
    @partial_name_element = "##{@partial_name}"
    case_doc_id = params[:department_doc][:case_doc_id]

    if case_doc_id.blank?
      case_doc = @main_case.case_docs.new(case_doc_params)
      respond_to do |format|
        if case_doc.save
          flash.now[:notice] = "文件上传成功！"
          format.js
        else
          flash.now[:warning] = "文件上传失败，请重新上传！#{case_doc.errors.messages}"
          format.js
        end
      end
    else
      case_doc = DepartmentDoc.find(case_doc_id)
      respond_to do |format|
        if case_doc.update(case_doc_params)
          flash.now[:notice] = "文件上传成功！"
          format.js
        else
          flash.now[:warning] = "文件上传失败，请重新上传！#{case_doc.errors.messages}"
          format.js
        end
      end
    end

  end

  # 更改案件状态响应的方法
  # method patch
  # params page_type String
  # params case_stage String
  # redirect to page_type => url 根据传过来的page_type返回到指定页面
  def update_case_stage
    page_type = params[:main_case][:page_type]
    case_stage = params[:main_case][:case_stage]
    archive_location = params[:main_case][:archive_location]
    # 这个是aasm的改变案件状态的方法名
    # 因为该方法名是turn_{case_stage}的形式的，需要用到动态派发的技术
    turn_case_stage_sym = "turn_#{case_stage}!".to_sym

    # 根据参数{page_type}来判断是要跳转到哪个页面
    case page_type
    when 'filing_info'
      redirect_url = filing_info_main_case_url(@main_case)
    when 'payment_order_management'
      redirect_url = payment_order_management_main_case_url(@main_case)
    when 'case_executing'
      redirect_url = case_executing_main_case_url(@main_case)
    when 'closing_case'
      redirect_url = closing_case_main_case_url(@main_case)
    when 'case_memos'
      redirect_url = case_memos_main_case_url(@main_case)
    when 'express_orders'
      redirect_url = express_orders_main_case_url(@main_case)
    when 'edit'
      redirect_url = edit_main_case_url(@main_case)
    end

    respond_to do |format|
      if @main_case.respond_to? turn_case_stage_sym
        @main_case.send turn_case_stage_sym
        @main_case.update(archive_location: archive_location) unless archive_location.nil?
        format.html { redirect_to redirect_url, notice: '案件状态已经更新了！' }
      else
        format.html { redirect_to redirect_url, danger: '案件状态更新失败！' }
      end
    end
  end

  # 更新案件的财务状态
  # method patch
  def update_financial_stage
    financial_stage = params[:main_case][:financial_stage]
    # 这个是aasm的改变案件状态的方法名
    # 因为该方法名是turn_{case_stage}的形式的，需要用到动态派发的技术
    turn_financial_stage_sym = "turn_#{financial_stage}!".to_sym
    redirect_url = payment_order_management_main_case_url(@main_case)

    respond_to do |format|
      if @main_case.respond_to? turn_financial_stage_sym
        @main_case.send turn_financial_stage_sym
        format.html { redirect_to redirect_url, notice: '案件状态已经更新了！' }
      else
        format.html { redirect_to redirect_url, danger: '案件状态更新失败！' }
      end
    end
  end

  # 费用管理页面
  def payment_order_management
    @payment_orders = initialize_grid(@main_case.payment_orders,
                                      order: 'created_at',
                                      order_direction: 'desc',
                                      per_page: 10,
                                      name: 'payment_orders')

    @bills = initialize_grid(@main_case.bills,
                             order: 'created_at',
                             order_direction: 'desc',
                             per_page: 10,
                             name: 'bills')
    @bill = @main_case.bills.new

    @refund_orders = initialize_grid(@main_case.refund_orders,
                             order: 'created_at',
                             order_direction: 'desc',
                             per_page: 10,
                             name: 'refund_orders')
  end

  # 保存费用管理页面
  # method patch
  def save_payment_order
    respond_to do |format|
      if @main_case.update(payment_order_params)
        format.html { redirect_to payment_order_management_main_case_url(@main_case), notice: '缴费单已经成功更新了！' }
      else
        format.html { render :payment_order_management }
      end
    end
  end

  # 鉴定执行页面
  def case_executing
  end

  # ajax获取发票信息
  def request_bill
    if PaymentOrder.find_by(:id=>params['payment_order']).bill.blank?
      render json: {:type=>"",:organization=>"",:address=>"",:code=>"",:bank=>"",:phone=>""}.to_json
    else
      bill = Bill.where(:payment_order_id=>params['payment_order']).first
      render json: {:type=>bill.bill_type,:organization=>bill.organization,:address=>bill.address,:code=>bill.code,:bank=>bill.bank,:phone=>bill.phone}.to_json
    end
  end

  # ajax更新发票信息
  def update_bill
    bill = Bill.where(:payment_order_id=>params['payment_order']).try(:first)
    if bill.nil?
      Bill.create(:payment_order_id=>params['payment_order'],:bill_type=>params['type'],:organization=>params['orgnization'],:address=>params['address'],:code=>params['code'],:bank=>params['bank'],:phone=>params['phone'])
    else
      bill.update(:payment_order_id=>params['payment_order'],:bill_type=>params['type'],:organization=>params['orgnization'],:address=>params['address'],:code=>params['code'],:bank=>params['bank'],:phone=>params['phone'])
    end

    render json: {:msg=>"发表已更新"}.to_json
  end

  # 案件信息页面的用户搜索
  # method get
  # 参数 user_name 用户姓名
  # 模糊搜索
  def user_search
    user_name = params[:user_name]

    res = User.includes(:organization).where.not(user_type: :center_user).where('name like ?', "%#{user_name}%").map do |user|
      user.name = "#{ user.try(:name) } 所属机构：#{ user.organization.try(:name) }"
      user
    end

    render json: { users: res }
  end

  # 用户案件信息页面（编辑），选择了导入用户后或填写相关字段，可以点击新建委托人按钮
  # 系统首先创建一个委托方（organization），然后再再该委托方(organization)下创建一个委托人(user)
  # 系统会为该委托人创建系统用户，以用户的手机号作为login字段
  # method POST
  def create_organization_and_user
    org_name, org_addr, wtr_phone, user_name = params[:organization_name],
                                               params[:organization_addr],
                                               params[:wtr_phone],
                                               params[:user_name]
    area = _area_id(params[:province_id],
                    params[:city_id],
                    params[:district_id])

    org = Organization.find_or_create_by(name: org_name,
                                         org_type: :court,
                                         addr: org_addr,
                                         area_id: area,
                                         province_id: params[:province_id],
                                         city_id: params[:city_id],
                                         district_id: params[:district_id])

    respond_to do |format|
      if org.present?
        org_user = org.users.find_by_login(user_name)
        if org_user.nil?
          system_user = User.find_by_login(user_name)
          current_user_login = system_user.nil? ? user_name : (system_user.login + '01')
          @user = org.users.new(login: current_user_login,
                                name: user_name,
                                email: "boot@forensic.com",
                                password: '123456',
                                password_confirmation: '123456',
                                mobile_phone: wtr_phone,
                                commonly_used: true)
          if @user.save
            flash.now[:success] = "委托方和委托人创建成功！请用户使用账号：#{current_user_login}和密码：123456 登录"
            format.js
          else
            flash.now[:danger] = '系统中已经存在该委托方信息，请使用上面的下拉列表选择之后点击【导入】按钮'
            format.js
          end
        else
          flash.now[:danger] = '系统中已经存在该委托方信息，请使用上面的下拉列表选择之后点击【导入】按钮'
          format.js
        end
      else
        flash.now[:danger] = '委托方创建失败！请选择地区信息！'
        format.js
      end
    end
  end

  # 用户在鉴定执行页面点击文件名后的上传按钮，发送ajax请求到该方法
  # 方法返回js，动态的渲染上传文件的表单modal
  # 用户在表单modal中填写相关信息，并可以上传文件，完成文件的上传
  def display_dynamic_file_modal
    @case_doc = DepartmentDoc.find(params[:case_doc_id])
    case @case_doc.case_stage.to_sym
    when :executing
      @partial_name = 'executing_case_docs'
      @case_stage = :executing
    when :archived
      @partial_name = 'closing_case_docs'
      @case_stage = :archived
    end

    respond_to do |format|
      format.js
    end
  end

  # 待立案的案件列表
  def pending_cases
    current_org = @current_user.organization
    redirect_to root_path, notice: '请您关联相关机构' and return if current_org.nil?

    data = MainCase.where(department_id: @current_user.departments.split(','), case_stage: :pending)
    @main_cases = initialize_grid(data,
                                  include: :transfer_docs,
                                  enable_export_to_csv: true,
                                  csv_file_name: 'main_cases',
                                  csv_field_separator: ',',
                                  per_page: 50,
                                  order: 'created_at',
                                  order_direction: 'desc',
                                  name: 'main_cases_grid')

    export_grid_if_requested('main_cases_grid' => 'main_cases_grid')
  end

  # 用户在委托单中点击【认领】按钮，系统会跳转到该action
  # 该action和new页面基本一致但是需要预先设置部分字段的值，根据传进来的委托单的内容
  def new_with_entrust_order
    @entrust_order = EntrustOrder.find(params[:entrust_order_id])
    @wtr = @entrust_order.user
    wtr_org = @entrust_order.organization
    @main_case = @entrust_order.build_main_case({ anyou: @entrust_order.anyou,
                                                  case_property: @entrust_order.case_property,
                                                  matter_demand: @entrust_order.matter_demand,
                                                  base_info: @entrust_order.base_info,
                                                  commission_date: @entrust_order.created_at,
                                                  province_id: wtr_org.province_id,
                                                  city_id: wtr_org.city_id,
                                                  district_id: wtr_org.district_id,
                                                  organization_name: wtr_org.name,
                                                  user_name: @wtr.name,
                                                  wtr_phone: @wtr.mobile_phone,
                                                  organization_addr: wtr_org.addr,
                                                  matter: @entrust_order.matter,
                                                  department_id: @entrust_order.department.try(:id)})
    @main_case.build_appraised_unit(@entrust_order.appraised_unit.attributes)
    @main_case.transfer_docs.build

    # 设置鉴定事项
    set_department_matters if !@entrust_order.department.try(:id).nil?

    # 设定案件类型
    set_case_types
  end

  # 结案主页面
  def closing_case
  end

  # 更新文档是否通过
  # method POST
  # params doc_id
  # params true | false
  # no return 不返回任何结果
  def update_doc_is_passed
    case_doc = DepartmentDoc.find(params[:doc_id])
    case_doc.update(is_passed: params[:is_passed])
    return
  end

  # 便签主页面
  # 「鉴定人」和 「立案人」可以看到除了仅自己可见的其他所有便签（当然自己的设置的仅自己可见自己仍然可以看到）
  # 「委托人」可以看到可见范围是 案件 和 本案件和领导
  # 「鉴定中心的科室主任」的可见范围是 本案件和领导
  # 「鉴定助理」可以看到 本案件 和 案件内部
  def case_memos
    @case_memos = if @main_case.temp_ident_user?(@current_user) || @main_case.case_filer?(@current_user)
      @main_case.case_memos.where.not(visibility_range: :only_me)
    elsif @main_case.assistant?(@current_user)
      @main_case.case_memos.where(visibility_range: [:current_case, :inner_current_case])
    elsif @main_case.wtr?(@current_user)
      @main_case.case_memos.where(visibility_range: [:current_case, :current_case_and_leader])
    elsif @current_user.center_department_director_user?
      @main_case.case_memos.where(visibility_range: :current_case_and_leader)
    else
      MainCase.none
    end.or(@main_case.case_memos.where(user_id: @current_user.id)).or(@main_case.case_memos.where(visibility_range: :all_user)).order(:created_at).uniq

    @case_memo = @main_case.case_memos.new
  end

  # 在案件下新建一个便签
  # 如果用户不是：鉴定人 or 委托人 or 该案件的科室主任 or 立案人，则系统不允许该用户创建便签
  def create_case_memo
    redirect_to case_memos_main_case_url(@main_case), alert: '您的没有在该案件创建便签的权限！' and return if not (@main_case.temp_ident_user?(@current_user) || @main_case.wtr?(@current_user) || @current_user.center_department_director_user? || @current_user.center_admin_user? || @current_user.center_filing_user?)

    @case_memo = @main_case.case_memos.new(case_memo_params)
    @case_memo.user = @current_user

    respond_to do |format|
      if @case_memo.save
        format.html { redirect_to case_memos_main_case_url(@main_case), notice: '便签创建成功！' }
      else
        format.html { redirect_to case_memos_main_case_url(@main_case), alert: '便签创建失败！请填写便签内容，并选择可见范围' }
      end
    end
  end

  # 案件进程
  def case_process_records

  end

  # 统计页面
  def personal_count
    @data = {}

    if @current_user.client_entrust_user?
      @data['entrust_user'] = {}
      my_case = MainCase.where(:wtr_id =>@current_user.id)

      @data['entrust_user']['cases_count'] =[]
      my_cases_center_ids_map = my_case.select(:organization_id).map{|e|e.organization_id}.uniq
      my_cases_center_ids_map.each do |e|
        center_name = e.nil? ? "未指定鉴定中心": Organization.find_by(id:e).name
        @data['entrust_user']['cases_count'] << {"name":center_name,"y":MainCase.where(:wtr_id =>@current_user.id).where(:organization_id =>e).count}
      end

      @data['entrust_user']['stage_count'] =[]
      case_stage = [ :pending, :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close ]
      case_stage.each do |e|
        @data['entrust_user']['stage_count'] << {"name":MainCase::CASE_STAGE_MAP[e],"count":my_case.where(case_stage:e).count}
      end

      @data['entrust_user']['month_mycase_count'] =[]
      this_month_begin = Time.now.at_beginning_of_month
      this_month_end = Time.now
      @data['entrust_user']['month_mycase_count'] << {"count":my_case.where(created_at: this_month_begin..this_month_end).count,"time":this_month_begin.strftime("%Y-%m")}

      11.times do
        this_month_end = this_month_begin
        this_month_begin = this_month_begin - 1.month
        @data['entrust_user']['month_mycase_count'] << {"count":my_case.where(created_at: this_month_begin..this_month_end).count,"time":this_month_begin.strftime("%Y-%m")}
      end
      @data['entrust_user']['month_mycase_count'].reverse!
    end

    if @current_user.center_director_user?
      center_cases = @current_user.organization.main_cases
      @data['center_director_user'] = {}

      @data['center_director_user']['center_cases_count'] =[]
      wtr_orgs_map = center_cases.select(:organization_name).map{|e|e.organization_name}.uniq
      wtr_orgs_map.each do |e|
        @data['center_director_user']['center_cases_count'] << {"name":e,"y":center_cases.where(:organization_name =>e).count}
      end

      @data['center_director_user']['department_cases_count'] =[]
      department_ids_map = center_cases.select(:department_id).map{|e|e.department_id}.uniq
      department_ids_map.each do |e|
        department_name = e.nil? ? "未指定部门": Department.find_by(id:e).name
        @data['center_director_user']['department_cases_count'] << {"name":department_name,"y":center_cases.where(:department_id =>e).count}
      end

      @data['center_director_user']['stage_count'] =[]
      case_stage = [ :pending, :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close ]
      case_stage.each do |e|
        @data['center_director_user']['stage_count'] << {"name":MainCase::CASE_STAGE_MAP[e],"count":center_cases.where(case_stage:e).count}
      end

      @data['center_director_user']['month_mycase_count'] =[]
      this_month_begin = Time.now.at_beginning_of_month
      this_month_end = Time.now
      @data['center_director_user']['month_mycase_count'] << {"count":center_cases.where(created_at: this_month_begin..this_month_end).count,"time":this_month_begin.strftime("%Y-%m")}

      11.times do
        this_month_end = this_month_begin
        this_month_begin = this_month_begin - 1.month
        @data['center_director_user']['month_mycase_count'] << {"count":center_cases.where(created_at: this_month_begin..this_month_end).count,"time":this_month_begin.strftime("%Y-%m")}
      end
      @data['center_director_user']['month_mycase_count'].reverse!

      # 组合图二维饼图的数据(省市查看案件数据量)
      province_count_hash = center_cases.group(:province_id).count
      province_count_cate = []
      @data['center_director_user']['province_count_count'] = {}
      @data['center_director_user']['province_count_count']['data'] = province_count_hash.map do |key, value|
        province = Area.find_by_id key
        city_cate = []
        city_value = []
        if province.present?
          province_count_cate << province.name
          city_ids = province.children.pluck(:id)
          city_cases = center_cases.where(city_id: city_ids).group(:city_id).count
          city_cases.each do |key, value|
            city = province = Area.find_by_id key
            city_cate << city.name
            city_value << value
          end
        end

        {
            y: value,
            drilldown: {
                name: province.name,
                categories: city_cate,
                data: city_value,
            }
        }
      end
      @data['center_director_user']['province_count_count']['province_count_cate'] = province_count_cate
    end

    if  @current_user.center_department_director_user?
      @current_department = Department.find_by(id: params[:department_id])
      @data['center_department_director_user'] = {}
      @data['center_department_director_user']["departments_select"] = @current_user.departments.split(",").map{|e| {"name":Department.find_by(id:e).name,"id":e}}
      @data['center_department_director_user']['department_selected'] = params[:department_id].blank? ? @data['center_department_director_user']["departments_select"][0][:id] : params[:department_id]
      department_cases = MainCase.where(:department_id =>@data['center_department_director_user']['department_selected'])

      @data['center_department_director_user']['stage_count'] =[]
      case_stage = [ :pending, :add_material, :filed, :rejected, :executing, :executed, :apply_filing, :close ]
      case_stage.each do |e|
        @data['center_department_director_user']['stage_count'] << {"name":MainCase::CASE_STAGE_MAP[e],"count":department_cases.where(case_stage:e).count}
      end

      @data['center_department_director_user']['month_mycase_count'] =[]
      this_month_begin = Time.now.at_beginning_of_month
      this_month_end = Time.now
      @data['center_department_director_user']['month_mycase_count'] << {"count":department_cases.where(created_at: this_month_begin..this_month_end).count,"time":this_month_begin.strftime("%Y-%m")}

      11.times do
        this_month_end = this_month_begin
        this_month_begin = this_month_begin - 1.month
        @data['center_department_director_user']['month_mycase_count'] << {"count":department_cases.where(created_at: this_month_begin..this_month_end).count,"time":this_month_begin.strftime("%Y-%m")}
      end

      @data['center_department_director_user']['month_mycase_count'].reverse!
    end
  end

  # 案件详情页
  def show_payment_order
    @payment_order = PaymentOrder.find_by_id(params[:payment_order_id])
    render 'payment_orders/finance_edit'
  end

  # 导出CSV方法
  def export_csv

  end

  def print_transfer_doc_barcode
    if params[:transfer_doc_id]
      @transfer_doc = TransferDoc.find(params[:transfer_doc_id])
      @main_case = @transfer_doc.main_case
      @barcode_image = @transfer_doc.barcode_image
    elsif params[:main_case_id]
      @main_case = MainCase.find(params[:main_case_id])
      @barcode_image = @main_case.barcode_image
    end

    render :layout => false
  end

  # 用户在案件中查看快递轨迹
  def express_orders
    current_organization = @current_user.organization
    @express_orders = @main_case.express_orders
    @recive_express_order = ReciveExpressOrder.new
    @express_order = ExpressOrder.new
  end

  # 返回案件的快递信息
  def express_route
    @express_num = params[:express_num]
    @express_type = params[:express_type]
    trace_hash = { "traceNo" => @express_num }.to_json
    private_key = '74C258A9EB489431'
    md5_digest = Digest::MD5.hexdigest(trace_hash + private_key)
    dataDigest = Base64.strict_encode64(md5_digest)
    msgBody = URI.encode(trace_hash)
    _params = { dataDigest: dataDigest,
                msgBody: msgBody,
                serialNo: '2',
                dataType: '1',
                batchNo: '999',
                receiveID: 'JDPT',
                sendDate: Time.now.strftime('%Y%m%d%H%M%S'),
                msgKind: 'zhijian_JDPT_TRACE',
                proviceNo: '99',
                sendID: 'zhijian',
              }
    url = URI('http://211.156.195.29/querypush-twswn/mailTrack/queryMailTrackWn/plus')
    url.query = URI.encode_www_form(_params)
    @result = HTTParty.post(url, headers: { 'Content-Type' => 'text/plain;charset=UTF-8' } )
    @result = JSON.parse(@result)

    respond_to do |format|
      format.js
    end
  end

  def print_express_order_page
    @sender = Organization.first
    @reciver = ReciveExpressOrder.find_by(order_num: params[:order_num])
    render :layout => false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_main_case
      @main_case = MainCase.find(params[:id])
    end

    # Never trust parameters from the scary intercase_executingnet, only allow the white list through.
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
                                        :wtr_phone,
                                        :organization_phone,
                                        :organization_addr,
                                        :department_id,
                                        :anyou,
                                        :case_property,
                                        :commission_date,
                                        :pay_date,
                                        { entrust_docs: [] },
                                        { matter: [] },
                                        :matter_demand,
                                        :base_info,
                                        :entrust_order_id,
                                        :wtr_id,
                                        :appraisal_opinion,
                                        :original_appraisal_opinion,
                                        :is_repeat,
                                        :data_str,
                                        :archive_location,
                                        :org_case_number,
                                        :forensic_case_number,
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
                                                                    :nationality,
                                                                    :_destroy])
    end

    def case_doc_params
      params.require(:department_doc).permit(:name,
                                             :doc_code,
                                             :check_archived,
                                             :check_archived_no,
                                             :attachment,
                                             :case_stage)
    end

    def payment_order_params
      params.require(:main_case).permit(:case_stage,
                                        payment_orders_attributes: [ :payer,
                                                                     :payer_contacts,
                                                                     :payer_contacts_phone,
                                                                     :consigner,
                                                                     :consiggner_contacts,
                                                                     :consiggner_contacts_phone,
                                                                     :appraisal_cost,
                                                                     :business_cost,
                                                                     :appear_court_cost,
                                                                     :investigation_cost,
                                                                     :other_cost,
                                                                     :consult_cost,
                                                                     :total_cost,
                                                                     :payment_type,
                                                                     :payment_date,
                                                                     :payment_people,
                                                                     :payment_in_advance,
                                                                     :payment_accept_type,
                                                                     :take_bill,
                                                                     :id,
                                                                     :assist_ident_user,
                                                                     :_destroy, refund_orders_attributes: [ :id,
                                                                                                            :_destroy,
                                                                                                            :total_cost,
                                                                                                            :appraisal_cost,
                                                                                                            :business_cost,
                                                                                                            :appear_court_cost,
                                                                                                            :investigation_cost,
                                                                                                            :other_cost,
                                                                                                            :consult_cost,
                                                                                                            :refund_cost,
                                                                                                            :payee_id,
                                                                                                            :refund_dealer_id,
                                                                                                            :refund_checker_id ] ])
    end

    def case_memo_params
      params.require(:case_memo).permit(:content, :visibility_range)
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
        @department_matters = @main_case.department.matter.split(',').map { |matter| [matter, matter] }
        @selected_matters = JSON.parse(@main_case.matter).map { |matter| matter }
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

    # 指定给当前机构的委托单
    def set_entrust_orders
      entrust_orders = @current_user.organization.entrust_orders.unclaimed
      @entrust_orders = []
      unless entrust_orders.empty?
        @entrust_orders = entrust_orders.map do|order|
          ["委托联系人：#{order.user.try(:name)} 被鉴定人：#{order.appraised_unit.try(:name)} 科室：#{order.department.try(:name)} 鉴定事项：#{ order.matter.nil? ? '' : JSON.parse(order.matter).join(',')}", order.id]
        end
      end
    end

    def forbid_admin_user
      if @current_user.admin?
        redirect_to organizations_path, notice: '管理员无权对案件进行管理！'
      end
    end

    def check_if_has_department
      redirect_to root_path, notice: '请您关联相关科室' and return if @current_user.departments.nil?
    end

    # 新建和编辑页面需要对应将科室的选择框限定在当前用户所属于的科室
    # 如果当前用户没有科室，却能点进到案件的编辑中，则说明是领导，则要返回所有的科室列表
    def set_departments
      # 如果当前用户没有关联科室则返回所有当前机构科室列表
      if @current_user.departments.nil?
        departments = @current_user.organization.departments
      else
        departments = Department.where(id: @current_user.departments.split(','))
      end

      if departments.empty?
        @departments = []
      else
        @departments = departments.map { |department| [department.name, department.id] }
      end
    end

    # 将摄像头上传的数据attach
    def attach_data_str(main_case, data_str)
      main_case.decode_base64_image data_str
    end

    def set_filter_instance(data, current_user)
      if params["main_cases_grid"] && params["main_cases_grid"]["export"].nil? && params["main_cases_grid"]["page"].nil?
        province_id = params["main_cases_grid"]["f"]["province_id"][0] if params["main_cases_grid"]["f"]["province_id"]
        city_id = params["main_cases_grid"]["f"]["city_id"][0] if params["main_cases_grid"]["f"]["city_id"]

        department_name = params["main_cases_grid"]["f"]["departments.name"][0] if params["main_cases_grid"]["f"]["departments.name"]
        ident_users = params["main_cases_grid"]["f"]["ident_users"][0] if params["main_cases_grid"]["f"]["ident_users"]
        pass_user = params["main_cases_grid"]["f"]["pass_user"][0] if params["main_cases_grid"]["f"]["pass_user"]
        matter = params["main_cases_grid"]["f"]["matter"][0] if params["main_cases_grid"]["f"]["matter"]

        @search_type = params["main_cases_grid"]["f"].delete("search_type")[0] if params["main_cases_grid"]["f"]["search_type"]
        if @search_type
          search_date = params["main_cases_grid"]["f"].delete("search_date") if params["main_cases_grid"]["f"]["search_date"]
          if search_date
            search_start_date = Date.new(*search_date["fr"].split('-').map(&:to_i)).beginning_of_day
            search_end_date = Date.new(*search_date["to"].split('-').map(&:to_i)).end_of_day
            case @search_type
            when '受理'
              data = data.where(commission_date: search_start_date..search_end_date)
            when '立案'
              data = data.where(acceptance_date: search_start_date..search_end_date)
            when '结案'
              data = data.where(close_case_date: search_start_date..search_end_date)
            end

            @search_date_fr = search_date["fr"]
            @search_date_to = search_date["to"]
          end
        end
      end

      organizaton = current_user.organization
      @department = organizaton.departments.where(name: department_name).first
      if @department && @department.matter
        @matters = @department.matter.split(',').map { |matter| [ matter, matter ] }
      else
        @matters = []
      end

      users = @department.user_array if @department
      if @department && !users.empty?
        @users = users.map { |user| [ user.name, user.id ] }
      else
        @users = []
      end

      data
    end

    def check_department
      redirect_to main_cases_path, flash: { alert: '请设置科室！' } and return if @current_user.departments.nil?
    end
end
