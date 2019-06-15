class MainCasesController < ApplicationController
  before_action :set_main_case, only: [:show, :edit, :update, :destroy, :generate_case_no,
                                       :filing_info, :update_add_material, :update_filing,
                                       :update_reject, :payment, :create_case_doc, :payment_order_management,
                                       :save_payment_order]
  before_action :set_new_areas, only: [:new, :organization_and_user, :create]
  before_action :set_edit_areas, only: [:edit, :update]
  before_action :set_court_users, only: [:new, :edit, :create]
  before_action :set_anyou_and_case_property, only: [:new, :edit, :create]
  before_action :set_department_matters, only: [:edit, :update]
  before_action :set_case_types, only: [:edit, :update]
  skip_before_action :authorize, only: :payment
  skip_before_action :can, only: :payment

  # 我的案件页面
  # GET /main_cases
  # GET /main_cases.json
  # admin用户可以看到全部case的信息
  # 没有机构的用户调到首页，告诉用户去设置对应的机构
  # 通过用户的机构类型看如果是法院的话，就说明该用户为委托人，委托人的话只能看跟自己相关的case
  # 除去以上所有情况，剩下的用户都为鉴定中心的用，鉴定中心的用户在该action里
  def index
    if admin?
      data = MainCase
    elsif @current_user.organization.nil?
      redirect_to acceptable_url('sessions', 'index'), notice: '请您关联对应的机构'
    elsif @current_user.organization.org_type.to_sym == :court
      data = MainCase.where(wtr_id: @current_user.id)
    else
      current_org_cases = @current_user.organization.main_cases
      case_ids = current_org_cases.map { |main_case| main_case.id if main_case.ident_users.present? &&
                                                                     main_case.ident_users.split(',').include?(@current_user.id) }
      data = MainCase.where(id: case_ids)
    end

    @main_cases = initialize_grid(data, per_page: 20, name: 'main_cases_grid')
  end

  # 本科室案件页面
  # 本页面不为管理员和委托人这两种角色设计，请不要在这两个角色下添加该功能
  # 委托人没有这个页面
  # 鉴定中心的人所在科室下的所有案件
  # 针对本中心的人没有权限
  def department_cases
    redirect_to root_path, notice: '请您关联相关科室' and return if @current_user.department.nil?

    data = @current_user.department.main_cases
    @main_cases = initialize_grid(data, per_page: 20, name: 'main_cases_grid')

    render :index
  end

  # 本中心案件页面
  # 本页面不为管理员和委托人这两种角色设计，请不要在这两个角色下添加该功能
  # 委托人没有这个页面；【鉴定中心管理员】和【鉴定中心主任】有这个菜单（由于权限是灵活的只要给正确的角色配正确的权限即可）
  def center_cases
    redirect_to root_path, notice: '请您关联相关鉴定中心' and return if @current_user.organization.nil?

    data = @current_user.organization.main_cases
    @main_cases = initialize_grid(data, per_page: 20, name: 'main_cases_grid')

    render :index
  end

  # 已付款待立案页面
  # 通过财务状态：【已付款】和案件状态：【待立案】，筛选本中心的所有案件
  # 本页面属于角色为立案人
  def filed_unpaid_cases
    redirect_to root_path, notice: '请您关联相关鉴定中心' and return if @current_user.organization.nil?
    current_org_cases = @current_user.organization.main_cases
    data = current_org_cases.where(case_stage: :filed, financial_stage: :unpaid)

    @main_cases = initialize_grid(data, per_page: 20, name: 'main_cases_grid')

    render :index
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
    @wtr_phone = user.mobile_phone
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
                                   wtr_phone: @wtr_phone,
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
  # method patch
  # 参数 :material_cycle 补充材料周期
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
  # method patch
  def update_filing
    ident_users = params[:main_case][:ident_users].blank? ? "" : params[:main_case][:ident_users].join(',')
    respond_to do |format|
      if @main_case.update(identification_cycle: params[:main_case][:identification_cycle],
                           pass_user: params[:main_case][:pass_user],
                           sign_user: params[:main_case][:sign_user],
                           ident_users: ident_users,
                           payer: params[:main_case][:payer],
                           payer_phone: params[:main_case][:payer_phone],
                           amount: params[:main_case][:amount],
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
  # method patch
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
    case_doc = @main_case.case_docs.new(case_doc_params)

    respond_to do |format|
      if case_doc.save
        flash[:notice] = "文件上传成功！"
        format.js { render 'layouts/display_flash' }
      else
        flash[:warning] = "文件上传失败，请重新上传！"
        format.js { render 'layouts/display_flash' }
      end
    end
  end

  # 费用管理页面
  def payment_order_management
  end

  # 保存费用管理页面
  # method patch
  def save_payment_order
    respond_to do |format|
      if @main_case.update(payment_order_params)
        format.html { redirect_to payment_order_management_main_case_url(@main_case), notice: 'Main case was successfully updated.' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { render :edit }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
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

    res = User.includes(:organization).where('name like ?', "%#{user_name}%")

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

    org = Organization.new(name: org_name,
                           org_type: :court,
                           addr: org_addr,
                           area_id: area,
                           province_id: params[:province_id],
                           city_id: params[:city_id],
                           district_id: params[:district_id])
    binding.pry
    respond_to do |format|
      if org.save
        user = org.users.new(login: wtr_phone,
                             name: user_name,
                             email: "#{wtr_phone}@forensic.com",
                             password: 'Fc123456',
                             password_confirmation: 'Fc123456')
        if user.save
          flash[:success] = "委托方和委托人创建成功！请用户使用账号：#{wtr_phone}和密码：Fc123456 登录"
          format.js { render 'layouts/display_flash' }
        else
          flash[:danger] = '委托人创建失败！请填写委托人电话字段，或您填写的电话已被占用！'
          format.js { render 'layouts/display_flash' }
        end
      else
        flash[:danger] = '委托方创建失败！请选择地区信息，或该委托方已经被创建了！'
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
                                        :wtr_phone,
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
                                                                     :_destroy, refund_orders_attributes: [ :id,
                                                                                                            :_destroy,
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
