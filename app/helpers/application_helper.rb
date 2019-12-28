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

  def stringify_time(time_str)
    if time_str
      time_str.to_time.strftime('%Y年%m月%d日')
    else
      ''
    end
  end

  def get_distance_of_time(main_case)
    case main_case.case_stage.to_sym
    when :pending
      content_tag :div, class: "text-success" do
        '距离登记已过' + distance_of_time_in_words(Time.now, main_case.created_at, scope: 'datetime.distance_in_words')
      end
    when :add_material
      if main_case.material_cycle.nil?
        '请选择补充材料周期'
      else
        date_bool = Time.now <=> (main_case.created_at + main_case.material_cycle.days)
        date_pre_str = date_bool > 0 ?  '距补充材料规定日期已过' : '距离补充材料到期还剩'
        date_distance = distance_of_time_in_words(Time.now, main_case.created_at + main_case.material_cycle.days, scope: 'datetime.distance_in_words')
        if date_bool
          content_tag :div, class: "text-warning" do
            date_pre_str + date_distance
          end
        else
          content_tag :div, class: "text-muted" do
            date_pre_str + date_distance
          end
        end
      end
    else
      if main_case.identification_cycle.nil?
        '请选择鉴定周期'
      else
        date_bool = Time.now <=> (main_case.acceptance_date + main_case.identification_cycle.days)
        date_pre_str = date_bool > 0 ?  '结案已过' : '距离结案还剩'
        date_distance = distance_of_time_in_words(Time.now, main_case.acceptance_date + main_case.identification_cycle.days, scope: 'datetime.distance_in_words')
        if date_bool
          content_tag :div, class: "text-danger" do
            date_pre_str + date_distance
          end
        else
          content_tag :div, class: "text-muted" do
            date_pre_str + date_distance
          end
        end
      end
    end
  end
end
