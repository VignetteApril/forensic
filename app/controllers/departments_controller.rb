# -*- encoding : utf-8 -*-
class DepartmentsController < ApplicationController
  before_action :set_department, only: [:edit, :update, :destroy, :add_users, :add_users_submit, :remove_user_from_department]
  after_action "make_log", only: [:create, :update, :destroy, :add_users_submit, :remove_user_from_department]

  # 管理员进入“部门管理”功能，系统以树状方式显示所有部门列表。 
  # 部门列表页面显示“新增部门”按钮，针对每一个部门节点，系统显示“编辑”按钮、“删除”按钮和“人员”链接。
  def index
    init_bread('部门管理')
    @department = params[:id] ? Department.find(params[:id]) : Department.all.first
    d_string = []
    Department.order('sort_no').each do |d|
      d_string << {  id: d.id,
                     parent: d.parent ? d.parent.id : '#',
                     text: d.name,
                     state: { opened: false, selected: (d==@department ? true : false) },
                     a_attr: { href: "/departments?id=#{d.id}" },
                     type: d.leaf? ? 'department' : 'default' }
    end
    @departments_str = d_string # "[#{d_string[0, (d_string.length-1)]}]"
    @users = initialize_grid(@department.users, order: 'sort_no', order_direction: 'asc', per_page: 20, name: 'department_users_grid')
  end
    
  # 管理员点击部门列表页面中的“新增部门”按钮，系统显示“新增部门”表单页面。
  def new
    cal_bread('新建部门')
    @department = Department.find(params[:parent_id]).children.new
  end

  # 管理员针对某一个部门节点，点击“编辑”按钮，系统显示部门信息编辑表单页面。
  def edit
    cal_bread('编辑部门信息')
  end

  # 管理员填写新增的部门信息之后点击“提交”按钮，系统保存新部门信息并返回部门列表页面。
  def create
    @department = Department.find(department_params[:parent_id]).children.new(department_params)
    if (SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      # @department.orgnization_name = @current_user.orgnization_name
    end

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
    cal_bread('部门人员维护')
    if (SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      @users = initialize_grid( User, per_page: 50,
                                conditions: { orgnization_name: @current_user.orgnization_name },
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users' )
    else
      # @users = initialize_grid(User, per_page: 20, name: 'users')
      @users = initialize_grid( User, per_page: 50,
                                order: 'sort_no', order_direction: 'asc',
                                name: 'users' )
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_department
    @department = Department.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def department_params
    params.require(:department).permit(:parent_id, :name, :description, :code, :brief, :sort_no, :admin_level, :role_type, :contact, :orgnization_name)
  end
end
