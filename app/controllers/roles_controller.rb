# -*- encoding : utf-8 -*-
class RolesController < ApplicationController
  before_action :set_role, only: [:edit, :update, :destroy, :add_users, :add_users_submit, :remove_user_from_role]
  after_action :make_log, only: [:create, :update, :destroy, :add_users_submit, :remove_user_from_role]

  # 显示角色列表页面，默认显示所有系统角色，并且不需要分页显示
  # 系统在角色列表页面还需要显示“新建角色”按钮，同时针对每一个已有的角色，系统还需要显示“人员”链接和“编辑角色”、“删除角色”按钮。
  def index
    # 非管理员不能管理 【系统管理员】角色里的用户
    @roles = @current_user.admin? ? Role.all.order(:name) : Role.where.not(name: :admin_user).where.not(name: :client_entrust_user)
    @role = params[:role_id] ? Role.find_by_id(params[:role_id]) : @roles.first
    users = @current_user.admin? ? @role.users : @role.users.where(organization_id: @current_user.organization_id)

    @users = initialize_grid(users,
                             order: 'sort_no',
                             order_direction: 'asc',
                             per_page: 20,
                             name: 'role_users')
  end

  # 显示新建角色表单页面。 
  def new
    @role = Role.new
  end

  # 管理员点击角色列表页面中针对某一 角色的“编辑角色”按钮，系统显示该角色的编辑表单页面。
  def edit
  end

  # 在新建角色页面中，用户点击“提交”按钮，系统保存该角色并返回角色列表页面。
  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to roles_path, notice: '该角色已经成功创建！' }
        format.json { render :index, status: :created}
      else
        format.html { render :new }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # 管理员修改该角色的信息之后，点击“保存”按钮，系统保存该角色修改后的信息并返回角色列表页面。
  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to roles_path, notice: '该角色已经成功保存！' }
        format.json { render :index, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # 管理员点击角色列表页面中针对某一角色的“删除角色”按钮，系统弹出对话框要求用户进行确认，
  # 在管理员确认之后，系统删除该角色并返回角色列表页面。
  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to roles_url, notice: '该角色已经被删除了！' }
      format.json { head :no_content }
    end
  end
    
  # 管理员在角色人员列表页面中，点击 “加入”按钮,系统显示所有人员的列表
  def add_users
    if !@current_user.admin?
      @users = initialize_grid( @current_user.organization.users, per_page: 50,
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users' )
    else
      # @users = initialize_grid(User, per_page: 20, name: 'users')
      @users = initialize_grid( User, per_page: 50,
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users' )
    end
  end
  
  # 管理员通过姓名的关键字模糊搜索对列表进行过滤，然后选择某一个人员，点击“加入”按钮，系统将该人员加入该角色，并返回人员列表页面。
  def add_users_submit
    if params[:users] && params[:users][:selected]
      @selected = params[:users][:selected]
      @selected.each do |uid|
        @role.user_roles.find_or_create_by user_id: uid, role_id: @role.id
      end
    end
    redirect_to roles_path(role_id: @role.id), notice: "新的用户已经加入了该角色！"
  end
  
  # 管理员在角色人员列表页面中，针对某一个人员点击“移除”按钮，系统在要求管理员确认之后，将该人员移出该角色，并返回人员列表页面。
  def remove_user_from_role 
    @role.user_roles.where(user_id: params[:user_id]).take.destroy
    @users = initialize_grid(@role.users, per_page: 20, name: 'role_users')
    respond_to do |format|
      # format.html { render :role_users_grid }
      format.html { redirect_to roles_path(role_id: @role.id) }
      format.js
    end
  end
  
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_role
    @role = Role.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def role_params
    params.require(:role).permit(:name, :description, :r_type)
  end
end
