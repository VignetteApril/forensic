# -*- encoding : utf-8 -*-
require 'uri'
# require 'macaddr'
class ApplicationController < ActionController::Base
  include ApplicationHelper
  helper_method :can_sys?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize, :can
  before_action :get_notifications
  # before_action :set_back_session

  # 针对用户、角色、部门编辑的“数据”权限控制
  def can_sys?(sys_object=nil, key_field='orgnization_name')
    return true if @current_user.login == 'admin'
    return true if sys_object.nil?
    # current_user = User.find(session[:user_id])
    # 如果不是超级用户
    #     如果是本机构的对象，则：
    #         有权限
    #     否则
    #         无权限
    # 否则
    #     有权限

    if (SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      if @current_user.orgnization_name == sys_object[key_field]
        return true
      else
        return false
      end
    else
      return true
    end
  end

  protected

  # 针对ie浏览器规范中文文件名编码
  def get_ie_filename(filename)
    ba = request.user_agent.downcase
    if ba.include?('msie') || ba.include?('11.0') || ba.include?('edge')
      return CGI::escape(filename)
    else
      filename
    end
  end

  # 获取URL地址中不带参数的部分
  def clear_url(url_str)
    # 第二行和第三行分别应对：
    # 1. 附件浏览上一页和下一页的情况
    # 2. 通用行业数据查询的情况（show_result, view_pivot）
    return url_str.sub(/\/audit_object_attachments\/((\d)+)/, "/audit_object_attachments/show") if url_str =~ /(.)+\/audit_object_attachments\/((\d)+)/
    return url_str.blank? ?
             "" :
             url_str[ 0, ( url_str.index('?') ? url_str.index('?') : url_str.length ) ] +
             ( url_str.include?('show_result=') ? "?show_result=" : "" ) +
             ( url_str.include?('view_pivot=')  ? "?view_pivot="  : "" )

  end

  # 初始化面包屑栈
  def init_bread(i_title, i_url_str=request.url)
    session[:bread] = [ { "title" => '主页',  "url_str" => main_app.root_path() },
                        { "title" => i_title, "url_str" => i_url_str } ]
    session[:bread_clear] = [ main_app.root_path(), clear_url(i_url_str) ]
  end

  # 根据当前页面，计算面包屑栈数据
  # 如果是新的页面，则push一项进入栈
  # 如果是当前页面，则栈内容不变
  # 如果当前页面是栈中的一项，则弹出栈中的部分内容
  def cal_bread(c_title, c_url_str=request.url)
    # if session[:bread_clear] && session[:bread_clear].include?( clear_url(c_url_str) )
    if session[:bread] && session[:bread].map{ |b| b['url_str'] }.include?( c_url_str )
        # 如果当前面包屑路径中已经包含当前请求的地址，则弹出栈
      while session[:bread_clear][-1] != clear_url(c_url_str) do
        session[:bread].delete_at(-1)
        session[:bread_clear].delete_at(-1)
      end
      session[:bread][-1] = { "title" => c_title, "url_str" => c_url_str }
    else
      # 否则将当前地址压入栈
      if session[:bread_clear].nil?
        session[:bread] = [ { "title" => '主页',  "url_str" => main_app.root_path() } ]
        session[:bread_clear] = [ main_app.root_path() ]
      end
      session[:bread] << { "title" => c_title, "url_str" => c_url_str }
      session[:bread_clear] << clear_url(c_url_str)
    end
  end

  # 用户登录验证
  def authorize
    if session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        session[:user_id] = user.id
        user.update_columns(session_id: session.id) if FORBID_SHADOW_LOGIN
        @current_user = user
      end
    else
      redirect_to main_app.login_url, notice: ("请您先登录系统" unless (controller_name == 'session' && action_name == 'index'))
      return
    end

    if @current_user.blank?
      redirect_to main_app.login_url, notice: ("请您先登录系统" unless (controller_name == 'session' && action_name == 'index'))
      return
    end
    if @current_user.session_id != session.id and FORBID_SHADOW_LOGIN
      # session[:user_id] = nil
      redirect_to main_app.login_url, notice: ("您的账号在其它位置登录过，请您重新登录" unless (controller_name == 'session' && action_name == 'index'))
      return
    end
    if !@current_user.changed_password && !(controller_name == "users" && (action_name == "edit_password" || action_name == "update_password"))
      # session['cas']['user'] = @current_user.login
      # session['cas']['extra_attributes'] = { id: @current_user.id, session_id: @current_user.session_id, name: @current_user.name }
      redirect_to main_app.edit_password_user_path(@current_user), notice: "您初次登录系统（或者刚刚初始化过密码），所以必须先修改密码才能继续使用。"
      return
    end
  end

  # 用户权限验证
  def can(c_name=controller_path, a_name=action_name)
    return true if @current_user.login == 'admin'
    return true if can?(c_name, a_name)

    redirect_to acceptable_url(c_name, a_name), notice: "对不起，您没有使用该功能的权限。"
  end

  # 获得已登录用户的个人事务提醒
  def get_notifications
    if @current_user
      @my_notifications = Notification.where(user_id: @current_user&.id, status: '未读').order('created_at DESC').limit(20)
    else
      @my_notifications = nil
    end
  end

  # 根据用户需要访问的无权限的地址，返回一个可访问的地址
  # 1. 所在功能模块的INDEX页面
  # 2. 所在功能模块所在的频道中第一个能访问的功能模块
  # 3. 系统首页
  def acceptable_url(controller, action)

    # current_user = User.find(session[:user_id])
    APPS.each do |channel|
      next if channel["module_chain"].nil?
      channel["module_chain"].each do |m|
        if m["controller"] == controller && (m["action"] || 'index') == action
          # 1. 返回需要访问的功能模块的首页
          @current_user.roles.each do |r|
            r.features.each do |f|
              if f.controller_name == controller && f.action_names.split(",").include?(m["action"].nil? ? 'index' : m["action"])
                return "/#{controller}/#{m["action"]}"
              end
            end
          end
          # 2. 如果需要访问的应用的首页也没有权限的话，则返回所在功能模块所在的频道中第一个能访问的功能模块
          channel["module_chain"].each do |mm|
            @current_user.roles.each do |r|
              r.features.each do |f|
                if f.controller_name == mm["controller"] && f.action_names.split(",").include?(mm["action"].nil? ? 'index' : mm["action"])
                  return "/#{mm["controller"]}/#{mm["action"]}"
                end
              end
            end
          end

          # 3. 如果还没有权限的话，则返回到系统首页面
          return "/"
        end
      end
    end
    return "/"
  end

  # 记录系统日志
  def make_log(object=0, keyword="")
    # return if get_license_type == 'application'
    log_msg = "**********\n" + 
              "Time: " + Time.now.to_s(:db) + ", " +
              "UID: " + @current_user&.id.to_s + ", " +
              "UName: " + @current_user&.name.to_s + ", " +
              "UIP: " + request.remote_ip + "\n" +
              "RequestURL: " + request.original_url + ' , ' +
              "RequestMethod: " + request.request_method + ", " +
              "QueryParams: " + request.query_parameters.to_s + "\n" +
              "RequestBody: " + request.POST.to_s + "\n"
    @ilog = SysLog.where(log_date: Date.today, user_id: @current_user&.id).take
    if @ilog
      @ilog.update_attribute :log_content, (@ilog.log_content + log_msg)
    else
      SysLog.create user_id: @current_user&.id, log_date: Date.today, log_content: log_msg
    end
  end

  # 判断当前用户是否是平台管理员
  def admin?
    !(SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
  end

  # 判断当前地区的id
  def _area_id(province_id, city_id, district_id)
    if !district_id.blank?
      district_id
    else
      if !city_id.blank?
        city_id
      else
        province_id
      end
    end
  end
end
