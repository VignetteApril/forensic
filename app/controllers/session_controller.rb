# -*- encoding : utf-8 -*-
class SessionController < ApplicationController
  layout "login", only: [:new, :aologin]
  skip_before_action :authorize, only: [:create, :new, :destroy, :aosignin, :aologin]
  skip_before_action :can, only: [:index, :create, :new, :destroy, :ao, :aologin, :aosignin]
  
  # 显示系统登录之后的首页
  def index
    session[:bread] = [ { "title" => '主页',  "url_str" => root_path() } ]
    session[:bread_clear] = [ root_path() ]
    
    @base_date = SysLog.where(user_id: @current_user.id).order("log_date DESC") # .first.log_date
    make_log(@current_user) if @base_date && !@base_date.empty? && @base_date.first.log_date < RELEASE_NOTES.last['date']
  end
  
  # 显示系统用户登录页面
  def new
  end
  
  # 用户登录信息提交，用户身份验证，成功之后转向系统首页
  def create
    if user = User.authenticate(params[:login], params[:password])
      redirect_to :login, flash: { danger: '用户被锁定，请联系管理员' } if user.is_locked == true

      session[:user_id] = user.id

      if params[:remember_me] == 'on'
        remember(user)
      else
        forget(user)
      end

      user.update(session_id: session.id) if FORBID_SHADOW_LOGIN
      redirect_to main_cases_path
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
    redirect_to :login, flash: { success: '您已经从系统中注销了' }
  end

  ######### 被审计单位用户登录相关

  # 被审计单位用户登录页面
  def aologin
  end

  # 被审计单位用户登录验证
  def aosignin
    if user = User.authenticate(params[:login], params[:password])
      if !user.is_org_of?('被审计单位')
        redirect_to '/login', notice: '您不是被审计单位用户，所以不能使用被审计单位专用的登录页面登录！'
      else
        session[:user_id] = user.id
        user.update(session_id: session.id) if FORBID_SHADOW_LOGIN
        redirect_to '/ao'
      end
    else
      redirect_to '/aologin', notice: "用户名或者密码输入错误"
    end
  end

  # 被审计单位用户主页
  def ao
    session[:bread] = [ { "title" => '主页',  "url_str" => '/ao' } ]
    session[:bread_clear] = [ '/ao' ]
    
    @base_date = SysLog.where(user_id: @current_user.id).order("log_date DESC") # .first.log_date
    make_log(@current_user) if @base_date && !@base_date.empty? && @base_date.first.log_date < RELEASE_NOTES.last['date']
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
