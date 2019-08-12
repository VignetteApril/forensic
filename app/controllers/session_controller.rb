# -*- encoding : utf-8 -*-
class SessionController < ApplicationController
  layout "login", only: [:new, :aologin]
  skip_before_action :authorize, only: [:create, :new, :destroy, :aosignin, :aologin]
  skip_before_action :can, only: [:index, :create, :new, :destroy, :ao, :aologin, :aosignin]
  
  # 显示系统登录之后的首页
  def index
    # session[:bread] = [ { "title" => '主页',  "url_str" => root_path() } ]
    # session[:bread_clear] = [ root_path() ]
    
    @base_date = SysLog.where(user_id: @current_user.id).order("log_date DESC") # .first.log_date
    make_log(@current_user) if @base_date && !@base_date.empty? && @base_date.first.log_date < RELEASE_NOTES.last['date']
  end
  
  # 显示系统用户登录页面
  def new
    if cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        redirect_to acceptable_url('main_cases', 'index')
      end
    end
  end
  
  # 用户登录信息提交，用户身份验证，成功之后转向系统首页
  def create
    if user = User.authenticate(params[:login], params[:password])
      redirect_to :login, flash: { danger: '用户被锁定，请联系管理员' } and return  if user.is_locked == true
      redirect_to :login, flash: { danger: '用户权限正在审核，请联系管理员' } and return  unless user.confirm? 
      redirect_to :login, flash: { danger: '用户被禁用，请联系管理员' } and return  if user.is_ban == true

      session[:user_id] = user.id

      if params[:remember_me] == 'on'
        remember(user)
      else
        forget(user)
      end

      user.update_columns(session_id: session.id) if FORBID_SHADOW_LOGIN

      # 登录成功后根据用户的角色跳转到对应的界面
      # 平台管理员          => 机构管理
      # 委托人             => 我的案件（委托人）
      # 鉴定中心立案人员    => 委托单（认领操作）
      # 鉴定中心管理员      => 科室管理
      # 鉴定中心主任        => 统计页面
      # 鉴定中心科室主任    => 统计页面
      # 鉴定人            => 我的案件（鉴定人）
      # 鉴定中心助理       => 我的案件（和鉴定人一样）
      # 鉴定中心档案管理员  => 待归档的案件列表
      # 鉴定中心财务人员    => 已立案待付款的案件列表

      if user.admin_user?
        redirect_to organizations_url
      elsif user.client_entrust_user?
        redirect_to wtr_cases_main_cases_url
      elsif user.center_admin_user?
        redirect_to departments_url
      elsif user.center_filing_user?
        redirect_to org_orders_entrust_orders_url
      elsif user.center_director_user?
        redirect_to personal_count_main_cases_url
      elsif user.center_department_director_user?
        redirect_to personal_count_main_cases_url
      elsif user.center_ident_user?
        redirect_to main_cases_url
      elsif user.center_assistant_user?
        redirect_to main_cases_url
      elsif user.center_archivist_user?
        redirect_to apply_filing_cases_main_cases_url
      elsif user.center_finance_user?
        redirect_to filed_unpaid_cases_main_cases_url
      else
        redirect_to main_cases_path
      end

    else
      redirect_to :login, flash: { danger: '用户名或者密码输入错误' }
    end
  end
  
  # 用户注销
  def destroy
    # 忘记永久记住的用户
    current_user = User.find(session[:user_id])
    current_user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)

    # 登出
    session[:user_id] = nil
    current_user.update_columns(session_id: nil)
    redirect_to :login, flash: { success: '您已经从系统中注销了' }
  end

  #记住用户,持久性存储登录信息(存cookie)
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 忘记持久会话
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
end
