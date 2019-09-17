# -*- encoding : utf-8 -*-
class DepartmentsController < ApplicationController
  before_action :set_department, only: [:edit, :update, :destroy, :add_users, :add_users_submit, :remove_user_from_department, :matters]
  after_action :make_log, only: [:create, :update, :destroy, :add_users_submit, :remove_user_from_department]
  skip_before_action :authorize, :can, only: [:matters]

  def index
    @departments = initialize_grid(@current_user.organization.departments, per_page: 20, name: 'departments_grid')
  end
    
  # 管理员点击部门列表页面中的“新增部门”按钮，系统显示“新增部门”表单页面。
  def new
    @department = Department.new
  end

  # 管理员针对某一个部门节点，点击“编辑”按钮，系统显示部门信息编辑表单页面。
  def edit
  end

  # 管理员填写新增的部门信息之后点击“提交”按钮，系统保存新部门信息并返回部门列表页面。
  def create
    @department = Department.new(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to departments_path(id: @department.id), notice: '部门已经成功创建了！' }
      else
        format.html { render :new, parent_id: @department.parent_id }
      end
    end
  end

  # 管理员在修改了该部门的信息之后，点击“保存”按钮，系统保存这一次修改，并返回部门列表页面。
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to departments_path(id: @department.id), notice: '部门信息已经成功保存了！' }
      else
        format.html { render :edit }
      end
    end
  end

  # 管理员针对某一个部门节点，点击“删除”按钮，系统弹出确认对话框，在管理员进行确认之后，系统删除该部门并返回部门列表页面。
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_url, notice: '该部门已经删除了！' }
    end
  end
  # 管理员在部门人员列表页面中，点击 “加入”按钮,系统显示所有人员的列表
  def add_users
    if (SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      @users = initialize_grid( User, per_page: 20,
                                conditions: { organization_id: @current_user.organization.id },
                                name: 'users' )
    else
      # @users = initialize_grid(User, per_page: 20, name: 'users')
      @users = initialize_grid( User, per_page: 20, name: 'users' )
    end
  end
  
  # 管理员通过姓名的关键字模糊搜索对列表进行过滤，然后选择某一个人员，点击“加入”按钮，系统将该人员加入该部门，并返回人员列表页面。
  def add_users_submit
    if params[:users] && params[:users][:selected]
      @selected = params[:users][:selected]
      @selected.each do |uid|
        # @department.user_departments.find_or_create_by user_id: uid, department_id: @department.id
        User.find(uid).update(department_id: @department.id)
      end
    end
    redirect_to departments_path(id: @department.id), notice: "新的用户已经加入了该角色！"
  end
  
  # 管理员在角色人员列表页面中，针对某一个人员点击“移除”按钮，系统在要求管理员确认之后，将该人员移出该部门，并返回人员列表页面。
  def remove_user_from_department
    # @department.user_departments.where(user_id: params[:user_id]).first.destroy
    User.find(params[:user_id]).update(department_id: nil)
    @users = initialize_grid(@department.users, per_page: 20, name: 'department_users_grid')
    respond_to do |format|
      # format.html { render "department", locals: {department: @department} }
      format.html { redirect_to departments_path(id: @department.id) }
      format.js
    end
  end

  def matters
    if @department.matter
      matters = @department.matter.split(',').map { |matter| { name: matter, id: matter } }
    else
      matters = []
    end

    respond_to do |format|
      format.json { render json: matters }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit( :parent_id,
                                          :name,
                                          :description,
                                          :code,
                                          :sort_no,
                                          :organization_id,
                                          :matter,
                                          :case_types,
                                          :abbreviation,
                                          :case_start_no)
    end
end
