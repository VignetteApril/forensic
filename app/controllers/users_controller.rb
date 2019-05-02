# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  layout 'system', except: [:edit_password]

  skip_before_action :can, only: [:edit_password, :update_password]
  before_action :set_user, only: [:edit, :update, :destroy, :reset_password, :update_password]
  after_action :make_log, only: [:create, :update, :destroy, :reset_password, :update_password]

  # 管理员进入“用户管理”功能，系统显示用户查询列表页面。
  # 管理员可以输入关键字进行搜索，可与对列表进行排序，列表应该进行分页显示。
  # 页面中醒目显示“新建用户”按钮；针对每一个用户，页面上显示：查看、编辑、禁用/启用、删除按钮。
  def index
    if admin?
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
      redirect_to "/", notice: "密码已经修改成功了！如果您是第一次登录本系统，请联系系统管理员要求给自己开通权限。"
    else
      render :edit_password
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:login, :name, :email,
                                 :hashed_password, :password, :password_confirmation,
                                 :department_id,
                                 :sort_no,
                                 :gender,
                                 :mobile_phone,
                                 :organization_id)
  end
end
