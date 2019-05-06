# -*- encoding : utf-8 -*-

module ApplicationHelper
  # include SLicense
  def admin?
    !(SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
  end

  # 用户权限验证功能模块
  def can?(controller_name, action_name)
    # return true if get_license_type == 'application'
    # current_user = User.find(session[:user_id])
    return true if @current_user.login == 'admin'
    @current_user.roles.each do |r|
      r.features.each do |f|
        return true if f.controller_name == controller_name && f.action_names.split(",").map{|a| a.strip}.include?(action_name)
      end
    end
    return false
  end

  # 获取当前的提醒分类
  def cur_notification_channel(name)
    NOTIFICATION_CHANNELS.each do |n|
      return n if n['name'] == name
    end
    return nil
  end

  # 组装侧边栏菜单项
  def get_sidebar_item(tcontroller, taction, turl='/', ticon='apple', tbadge='', ttitle='', tmethod='', byaction=false)
    l = "<li role='presentation'"
    if byaction
      if taction.blank? || taction == 'index'
        l += " class='active'" if controller.controller_name == tcontroller && controller.action_name == 'index'
      else
        l += " class='active'" if controller.controller_name == tcontroller && controller.action_name == taction
      end
    else
      l += " class='active'" if controller.controller_name == tcontroller
    end
    l += ">"
    a  = "<a class='text-center sidebar-a' href='#{turl}' #{tmethod == 'post' ? " data-method='post' " : " "} >"
    # i = "<div><div class='sidebar-icon'><span class='glyphicon glyphicon-" + ticon + "'  aria-hidden='true'></span></div>"
    i  = "<div>"
    i += "  <div class='sidebar-icon'><i class='fa fa-#{ticon}'></i></div>"
    i += "  <span class='badge' style='position:absolute;right:15px;top:15px'>#{tbadge.to_s}</span>" if tbadge && tbadge.to_i > 0
    i += "</div>"
    t = ttitle

    lend = "</a></li>"

    return raw(l + a + i + t + lend)
  end

  # 返回配置：部门非叶子节点是否可以拥有人员或者被审计对象？
  def can_has_users?(department)
    if !SysConfig.department_onlyleaf_can_has_user?
      return true
    elsif department.leaf?
      return true
    else
      return false
    end
  end

  # 组装面包屑
  def get_bread_crumb
    a = "<div class='row'><div class='col-sm-12'><ol class='breadcrumb'>"
    z = "</ol></div></div>"
    m = ""
    session[:bread].each do |b|
      m += "<li" + ( b==session[:bread][-1] ? " class='active'" : "" ) + ">" +
             ( b!=session[:bread][-1] ? "<a href='#{b['url_str']}'>" : "" ) +
               b["title"] +
             ( b!=session[:bread][-1] ? "</a>" : "" ) +
           "</li>"
    end
    return raw(a + m + z)
  end

  # 显示提示FLASH
  def get_notice_bar
    if flash.keys.count > 0
      flash.each do |msg_type, msg|
        msg_type = "info" if msg_type == "notice"
        a = "<div class='row'><div class='col-sm-12'>"
        b = "  <div class='alert alert-#{msg_type}' role='alert'>"
        c = "    <button class='close' type='button' data-dismiss='alert' aria-label='关闭'>"
        d = "      <span aria-hidden='true'>&times;</span>"
        e = "    </button>"

        m =      msg

        y = "  </div>"
        z = "</div></div>"

        return raw(a + b + c + d + e + m + y + z)
      end
    else
      return ""
    end
  end

  # 将utf8编码的原始文件转换成为gbk编码
  def conv_utf8_to_gbk(source, destination)
    s = File.open(source, "r")
    d = File.new(destination, "w+")
    s.each_line do |line|
      d.puts line.encode('gbk', 'utf-8').force_encoding('utf-8')
    end
    d.close
    s.close
  end

  # 从Redmine网站获取项目列表
  def get_project_list_from_redmine()
    begin
      JSON.parse(
        open(SysConfig.redmine_url + "/projects.json?key=" + SysConfig.redmine_api_key).read
      )["projects"].map do |p|
        [ 
          p["name"], 
          p["id"], 
          { 
            identifier: p["identifier"], 
            audit_object_id: p['custom_fields'].select{ |c| c['name'] == '被审计单位ID' }[0]['value'], 
            department_id: p['custom_fields'].select{ |c| c['name'] == '审计单位ID' }[0]['value'].to_i
          }
        ]
      end
    rescue
      []
    end
  end

  # 根据ID获得Redmine系统中的项目详情
  def get_project_detail_from_redmine(id)
    begin
      JSON.parse(
        open(SysConfig.redmine_url + "/projects/#{id}.json?key=" + SysConfig.redmine_api_key).read
      )["project"]
    rescue
      {}
    end
  end

  # 根据ID获得项目主页链接地址
  def get_project_url(id)
    SysConfig.redmine_url + "/projects/#{id}?key=" + SysConfig.redmine_api_key
  end

  # 根据ID获得Redmine系统中的文档详情
  def get_document_detail_from_redmine(id)
    begin
      JSON.parse( open(SysConfig.redmine_url + "/documents/#{id}.json?key=" + SysConfig.redmine_api_key).read )
    rescue
      {}
    end
  end

  # 从Redmine网站获取项目模板列表
  def get_template_list_from_redmine()
    begin
      [['默认类型', 0]] + JSON.parse(
        open(SysConfig.redmine_url + "/templates.json?key=" + SysConfig.redmine_api_key).read
      ).map do |p|
        [ 
          p["name"], 
          p["id"]
        ]
      end
    rescue
      ['默认类型', 0]
    end
  end

  def active_class(controller, *controller_name)
      if controller_name.include?(controller.controller_name)
        return 'list-group-item list-group-item-action active'
      else
        return 'list-group-item list-group-item-action'
      end
  end
end
