# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  skip_before_action :can, only: [:edit_password, :update_password,:new_consignor,:create_consignor]
  before_action :set_user, only: [:edit, :update, :destroy, :reset_password, :update_password, :confirm_user, :edit_org, :cancel_user, :update_confirm_user_org, :edit_self]
  after_action :make_log, only: [:create, :update, :destroy, :reset_password, :update_password]
  before_action :set_selected_departments, only: [:edit, :update, :new, :create, :edit_self]
  before_action :set_new_areas, only: [:new, :create,:new_consignor,:edit_org]
  before_action :set_edit_areas, only: [:edit, :update]
  skip_before_action :authorize, only: [:new_consignor,:create_consignor]
  skip_before_action :verify_authenticity_token, only: [:new_consignor,:create_consignor]

  # 管理员进入“用户管理”功能，系统显示用户查询列表页面。
  # 管理员可以输入关键字进行搜索，可与对列表进行排序，列表应该进行分页显示。
  # 页面中醒目显示“新建用户”按钮；针对每一个用户，页面上显示：查看、编辑、禁用/启用、删除按钮。
  def index
    if @current_user.admin?
      @users = initialize_grid( User, per_page: 20,
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users',
                                enable_export_to_csv: true, csv_file_name: 'users' )
    else
      @users = initialize_grid( User, per_page: 20,
                                conditions: { organization_id: @current_user.organization.try(:id) },
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users',
                                enable_export_to_csv: true, csv_file_name: 'users' )
    end
    export_grid_if_requested
  end

  # 用户查看某一个用户的详细信息
  def show
    @user = User.find(params[:id])
  end

  # 管理员在用户列表页面中点击“新建用户”按钮，系统显示新建用户表单页面。
  def new
    @user = User.new
  end

  # 针对用户列表中的某一个用户，管理员点击“编辑”按钮，系统显示该用户信息的编辑页面。
  def edit
  end

  # 管理员填写新用户之后点击“提交”按钮，系统保存新用户信息并返回用户列表页面。
  def create
    @user = User.new(user_params.merge({:password => 'Fc123456', :password_confirmation => 'Fc123456'}))
    @user.departments = user_params[:departments].join(',') unless user_params[:departments].blank?
    @user.organization = @current_user.organization unless @current_user.admin?

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: '新建用户成功啦，默认密码是 Fc123456' }
      else
        format.html { render :new }
      end
    end
  end

  # 管理员修改该用户信息之后，点击保存按钮，系统保存该用户信息，并返回用户列表页面。
  def update
    respond_to do |format|
      if @user.update(user_params)
        @user.update(departments: user_params[:departments].join(',')) unless user_params[:departments].blank?
        format.html { redirect_to users_url, notice: '用户信息已经成功保存了' }
      else
        format.html { render :edit }
      end
    end
  end

  # 针对用户列表中的某一个用户，管理员点击“删除”按钮，系统弹出确认对话框要求用户进行确认。
  # 在管理员确认之后，系统删除该用户信息并返回用户列表页面。
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: '该用户已经被删除了' }
    end
  end

  # 管理员将用户的密码初始化成为123456
  def reset_password
    respond_to do |format|
      if @user.update_attributes({:password => 'Fc123456', :password_confirmation => 'Fc123456', :changed_password => false})
        format.html { redirect_to users_url, notice: '用户已经重置成为Fc123456' }
      else
        format.html { render :index }
      end
    end
  end

  # 用户点击系统右上角个人设置菜单中的“修改密码”菜单项，系统显示修改密码页面。
  def edit_password
    @user = User.find_by_id(@current_user&.id)
  end

  # 用户填写原密码和新密码之后，提交，系统修改用户密码。
  def update_password
    @searhc_user = User.authenticate(@user.login, params[:old_password])
    if @searhc_user.nil?
      redirect_to edit_password_user_path, notice: '原始密码不正确'
    elsif @user.update_attributes({:password => params[:password], :password_confirmation => params[:password_confirmation], :changed_password => true})
      redirect_to "/", notice: "密码已经修改成功了！如果您是第一次登录本系统，请联系系统管理员要求给自己开通权限。"
    else
      flash[:danger] = "#{@user.errors.messages}"
      render :edit_password
    end
  end

  #委托人审核
  def confirm_users
    @request_users = initialize_grid(User.where(:confirm_stage=>:not_confirm),
                         order: 'created_at',
                         order_direction: 'desc',
                         per_page: 10,
                         name: 'request_users')
  end

  #委托人审核-同意
  def confirm_user
    @user.confirm_stage = :confirm
    respond_to do |format|
      if @user.save
        data = {
          keyword1: {
              "value": "#{@user.login}"
          },
          keyword2: {
              value: "已审核通过"
          }
        }
        send_wx_msg(@user, data)

        format.html { redirect_to confirm_users_users_path, notice: '已审核通过该用户' }
      else
        format.html { redirect_to confirm_users_users_path, notice: '未审核通过该用户' }
      end
    end
  end

  #委托人审核-驳回
  def cancel_user
    @user.confirm_stage = :cancel
    respond_to do |format|
      if @user.save
        data = {
          "keyword1": {
              "value": "#{@user.login}"
          },
          "keyword2": {
              "value": "已被驳回"
          }
        }
        send_wx_msg(@user,data) 

        format.html { redirect_to confirm_users_users_path, notice: '已驳回用户申请信息' }
      else
        format.html { redirect_to confirm_users_users_path, notice: '未驳回该用户' }
      end
    end
  end

  #委托人审核-编辑组织
  def edit_org
    @user_org = Organization.where(:name=>@user.organization_name).first
  end

  #委托人审核-编辑组织-提交
  def update_confirm_user_org
    if params['organization']['is_new_org'] == 'true'
      org = Organization.where(:name=>@user.organization_name).first
      unless org.update(:province_id=>params['organization']["province_id"],
        :city_id=>params['organization']["city_id"],
        :district_id=>params['organization']["district_id"],
        :area_id=>params['organization']["district_id"],
        :name=>params['organization']["name"],
        :is_confirm=>true
        )
        redirect_to edit_org_user_path(@user), notice: "#{@org.errors}"
      end
      @user.update(organization_id:org.id)
      @user.save
      redirect_to confirm_users_users_path, notice: "设置用户#{@user.name}机构为新增机构#{org.name}"
    else
      org =  Organization.find_by(:id=>params['organization']['organization_id'])
      @user.update(organization_id:org.id)
      @user.save
      redirect_to confirm_users_users_path, notice: "设置用户#{@user.name}机构为已有机构#{@user.organization.name}"
    end
  end

  #委托人注册
  def new_consignor
    @consignor_user = User.new
    render layout: 'login'
  end

  def edit_self
  end

  def update_edit_self
  end

  #委托人创建
  def create_consignor
    wtr_role = Role.where(name:'client_entrust_user').first

    if !Organization.where(:name=>params["user"]["organization_name"]).exists?

      org = Organization.new(:is_confirm=>false, :name=>params["user"]["organization_name"],:org_type=>:court,:province_id=>params['user']['province_id'],:city_id=>params['user']['city_id'],:district_id=>params['user']['district_id'],:area_id=>params['user']['district_id'])
      if org.save
        user = org.users.new(:confirm_stage=>:not_confirm, :name=>params["user"]["name"],:login=>params["user"]["login"],:email=>params["user"]["email"],:mobile_phone=>params["user"]["mobile_phone"],:password=>params["user"]["password"],:password_confirmation=>params["user"]["password_confirmation"])
        dep = org.departments.where(:name=>params["user"]["department_names"]).try(:first)
        if dep.nil?
          dep = org.departments.create(:name=>params["user"]["department_names"])
        end
        user.departments = dep.id.to_s
        if user.save
          wtr_role.user_roles.find_or_create_by user_id: user.id, role_id: wtr_role.id
          redirect_to '/login' ,flash: { success: '创建委托人成功,请登录' }
        else
          redirect_to '/users/new_consignor' ,flash: { danger: "创建委托人失败，#{user.errors.messages}" }
        end
      else
        redirect_to '/users/new_consignor' ,flash: { danger: "创建单位失败，#{org.errors}"}
      end

    else

      org = Organization.where(:name=>params["user"]["organization_name"]).first
      if org.users.where(:login=>params["user"]["login"]).exists?
        user = org.users.where(:login=>params["user"]["login"]).first
        if user.update(:password=>params["user"]["password"],:password_confirmation=>params["user"]["password_confirmation"])
          redirect_to '/login' ,flash: { success: '系统已经找到同名委托人并且重置密码,请登录' }
        else
          redirect_to '/users/new_consignor' ,flash: { danger: '系统已经找到同名委托人重置密码失败' }
        end
      else
        user = User.new(:confirm_stage=>:not_confirm, :name=>params["user"]["name"],:login=>params["user"]["login"],:email=>params["user"]["email"],:mobile_phone=>params["user"]["mobile_phone"],:password=>params["user"]["password"],:password_confirmation=>params["user"]["password_confirmation"])
        user.organization = org
        dep = org.departments.where(:name=>params["user"]["department_names"]).try(:first)
        if dep.nil?
          dep = org.departments.create(:name=>params["user"]["department_names"])
        end
        user.departments = dep.id.to_s
        if user.save 
          wtr_role.user_roles.find_or_create_by user_id: user.id, role_id: wtr_role.id
          redirect_to '/login' ,flash: { success: '创建委托人成功,请登录' }
        else
          redirect_to '/users/new_consignor' ,flash: { danger: "创建委托人失败，#{user.errors.messages}" }
        end
      end
    end
  end

  private
  def send_wx_msg(user,data)
    app_id = "wx5e9e5d5e051dcd16"
    secret = "370a22bff4b187b86aed5158489ff671"

    token_url  = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{app_id}&secret=#{secret}")
    token_res  = Net::HTTP.get_response(token_url)
    token = JSON.parse(token_res.body)["access_token"].to_s

    msg_url = URI("https://api.weixin.qq.com/cgi-bin/message/wxopen/template/send?access_token=#{token}")
    req_data = {
      "data": data, 
      "page":"pages/login/login",
      "touser": user.open_id,
      "template_id": "DmlBLeL8AJsT3tnJcXtQgNhIXTHLq8I3HTagSlurBsU",
      "form_id":user.form_id
    }
    response = Net::HTTP.post msg_url,req_data.to_json,"Content-Type" => "application/json"
    Rails.logger.info req_data.to_json
    Rails.logger.info "发送通知"
    Rails.logger.info response.body
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:login,
                                 :name,
                                 :email,
                                 :hashed_password,
                                 :password,
                                 :password_confirmation,
                                 { departments: [] },
                                 :sort_no,
                                 :gender,
                                 :mobile_phone,
                                 :organization_id,
                                 :province_id,
                                 :city_id,
                                 :district_id)
  end

  def set_selected_departments
    if  @user.nil? || @user.departments.blank?
      @departments_selected = []
    else
      @departments_selected = Department.where(id: @user.departments.split(',')).map { |department| department.id }
    end
  end

  def set_new_areas
    @provinces = Area.roots
    @cities = Area.where(area_type: 'city')
    @districts = @cities.first.children
  end

  def set_edit_areas
    city_id = @user.city_id
    @cities = Area.where(area_type: 'city')
    @districts = city_id.nil? ? [] : Area.find(city_id).children
  end
end

