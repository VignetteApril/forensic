desc "系统初始化功能和授权"
task :init_feature => :environment do
  puts "初始化所有的系统功能"

  features = YAML.load_file(Rails.root.join("config","config.yml"))["features"]

  features.each do |name, controller_name, action_names, app|
    f = Feature.where(name: name, app: app).take
    if f
      if f.controller_name != controller_name || f.action_names != action_names
        puts "更新功能：#{name}，#{controller_name}，#{action_names}"
        f.update :controller_name => controller_name, :action_names => action_names, :app => app
      elsif f.app != app
        puts "补齐APP名称：#{app}"
        f.update :app => app
      end
    else
      puts "新增功能：#{app}, #{name}，#{controller_name}，#{action_names}"
      Feature.create :name => name, :controller_name => controller_name, :action_names => action_names, :app => app
    end
  end
  Feature.all.each do |f|
    if features.select{ |ff| ff[0] == f.name and ff[3] == f.app }.empty?
      puts "删除功能：#{f.app}, #{f.name}，#{f.controller_name}，#{f.action_names}"
      f.destroy
    end
  end

  puts "为系统管理员授权"
  sysadmin = Role.find_by_name("系统管理员")
  Feature.all.each do |f|
    sysadmin.role_features.find_or_create_by(feature_id: f.id)
  end
end
