# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  # skip_before_action :authorize, only: [:list]
  skip_before_action :can, only: [:edit_password, :update_password]
  before_action :set_user, only: [:edit, :update, :destroy, :reset_password, :update_password]
  after_action "make_log", only: [:create, :update, :destroy, :reset_password, :update_password]

  # 管理员进入“用户管理”功能，系统显示用户查询列表页面。
  # 管理员可以输入关键字进行搜索，可与对列表进行排序，列表应该进行分页显示。
  # 页面中醒目显示“新建用户”按钮；针对每一个用户，页面上显示：查看、编辑、禁用/启用、删除按钮。
  def index
    init_bread('用户管理')
    if (SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      @users = initialize_grid( User, per_page: 20,
                                conditions: { orgnization_name: @current_user.orgnization_name },
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users',
                                enable_export_to_csv: true, csv_file_name: 'users' )
    else
      @users = initialize_grid( User, per_page: 20,
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users',
                                enable_export_to_csv: true, csv_file_name: 'users' )
    end
    export_grid_if_requested
  end

  # 用户查看某一个用户的详细信息
  def show
    cal_bread('用户详细信息')
    @user = User.find(params[:id])
  end

  # 管理员在用户列表页面中点击“新建用户”按钮，系统显示新建用户表单页面。
  def new
    cal_bread('创建用户')
    @user = User.new
  end

  # 针对用户列表中的某一个用户，管理员点击“编辑”按钮，系统显示该用户信息的编辑页面。
  def edit
    cal_bread('编辑用户信息')
  end

  # 管理员填写新用户之后点击“提交”按钮，系统保存新用户信息并返回用户列表页面。
  def create
    @user = User.new(user_params.merge({:password => '123456@Shike', :password_confirmation => '123456@Shike'}))

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: '新建用户成功啦，默认密码是 123456@Shike' }
      else
        format.html { render :new }
      end
    end
  end

  # 管理员修改该用户信息之后，点击保存按钮，系统保存该用户信息，并返回用户列表页面。
  def update
    # byebug
    respond_to do |format|
      if @user.update(user_params)
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
      if @user.update_attributes({:password => '123456@Shike', :password_confirmation => '123456@Shike', :changed_password => false})
        format.html { redirect_to users_url, notice: '用户已经重置成为123456@Shike' }
      else
        format.html { render :index }
      end
    end
  end

  # 用户点击系统右上角个人设置菜单中的“修改密码”菜单项，系统显示修改密码页面。
  def edit_password
    init_bread('修改个人密码')
    @user = User.find_by_id(@current_user&.id)
  end

  # 用户填写原密码和新密码之后，提交，系统修改用户密码。
  def update_password
    # byebug
    @searhc_user = User.authenticate(@user.login, params[:old_password])
    # byebug
    if @searhc_user.nil?
      redirect_to edit_password_user_path, notice: '原始密码不正确'
    elsif @user.update_attributes({:password => params[:password], :password_confirmation => params[:password_confirmation], :changed_password => true})
      # redirect_to edit_password_user_path, notice: '密码已经修改成功了'
      redirect_to "/", notice: "密码已经修改成功了！<br/><br/>如果您是第一次登录本系统，请联系系统管理员要求给自己开通权限。"
    else
      render :edit_password
    end
  end

  # 提供更新的用户列表API
  def list
    at_time = params[:time]
    new_users = User.where("created_at >= ?", at_time).map do |u|
      {
        :login => u.login,
        :name => u.name,
        :id_card_no => u.id_card_no,
        :email => u.email,
        :work_phone => u.work_phone,
        :position => u.position,
        :department => u.department&.name,
        :code => u.code,
        :sort_no => u.sort_no,
        :english_name => u.english_name,
        :politics_status => u.politics_status,
        :id_type => u.id_type,
        :gender => u.gender,
        :marital_status => u.marital_status,
        :top_education => u.top_education,
        :top_degree => u.top_degree,
        :rank => u.rank,
        :home_phone => u.home_phone,
        :work_fax => u.work_fax,
        :mobile_phone => u.mobile_phone,
        :email2 => u.email2,
        :country => u.country,
        :province => u.province,
        :city => u.city,
        :zip_code => u.zip_code,
        :address => u.address,
        :memo => u.memo,
        :orgnization_name => u.orgnization_name,
        :flag => 'new'
      }
    end
    updated_users = User.where("created_at < ? AND updated_at > ?", at_time, at_time).map do |u|
      {
        :login => u.login,
        :name => u.name,
        :id_card_no => u.id_card_no,
        :email => u.email,
        :work_phone => u.work_phone,
        :position => u.position,
        :department => u.department&.name,
        :code => u.code,
        :sort_no => u.sort_no,
        :english_name => u.english_name,
        :politics_status => u.politics_status,
        :id_type => u.id_type,
        :gender => u.gender,
        :marital_status => u.marital_status,
        :top_education => u.top_education,
        :top_degree => u.top_degree,
        :rank => u.rank,
        :home_phone => u.home_phone,
        :work_fax => u.work_fax,
        :mobile_phone => u.mobile_phone,
        :email2 => u.email2,
        :country => u.country,
        :province => u.province,
        :city => u.city,
        :zip_code => u.zip_code,
        :address => u.address,
        :memo => u.memo,
        :orgnization_name => u.orgnization_name,
        :flag => 'updated'
      }
    end
    respond_to do |format|
      format.json { render json: (new_users + updated_users).to_json }
    end
  end

  # 显示API KEY
  def show_api_key
    cal_bread("API接口键值")
  end

  # 生成API KEY
  def generate_api_key
    @current_user.api_key = SecureRandom.uuid
    @current_user.save
    redirect_to show_api_key_user_path(@current_user)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    if !(SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      @user = User.find(params[:id])
    else
      @user = User.where(id: params[:id], orgnization_name: @current_user.orgnization_name).take
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:login, :name, :id_card_no, :email, :work_phone, :position,
                                 :hashed_password, :salt, :password, :password_confirmation,
                                 :department_id,
                                 :code,
                                 :sort_no,
                                 :english_name,
                                 :politics_status,
                                 :id_type,
                                 :gender,
                                 :marital_status,
                                 :top_education,
                                 :top_degree,
                                 :rank,
                                 :home_phone,
                                 :work_fax,
                                 :mobile_phone,
                                 :email2,
                                 :country,
                                 :province,
                                 :city,
                                 :zip_code,
                                 :address,
                                 :memo,
                                 :orgnization_name)
  end
end
