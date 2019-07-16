# -*- encoding : utf-8 -*-

module ApplicationHelper
  # 用户权限验证功能模块

  def can?(controller_name, action_name)
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

  # system side bar active class
  def active_class(controller, *controller_name)
    if controller_name.include?(controller.controller_name)
      return 'app-menu__item active'
    else
      return 'app-menu__item'
    end
  end

  # application side bar active class
  def active_class_with_action(controller, controller_name, action_name)
    if controller_name == controller.controller_name && action_name == controller.action_name
      return 'app-menu__item active'
    else
      return 'app-menu__item'
    end
  end

  # top bar active class
  def top_bar_active_class(controller, controller_name, action_name)
    if controller_name == controller.controller_name && action_name == controller.action_name
      return 'nav-link active'
    else
      return 'nav-link'
    end
  end

  def court_user?
    @current_user.organization && @current_user.organization.org_type == 'court'
  end
end
