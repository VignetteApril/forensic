desc "系统初始化功能和授权"
task :init_feature => :environment do
  puts "初始化所有的系统功能"

  Role::NAME_TYPE.each do |key, value|
    puts "重新创建系统角色：#{value}"
    r_type = key == :client_entrust_user ? :court : :center
    Role.find_or_create_by name: key.to_sym, r_type: r_type
  end

  features = YAML.load_file(Rails.root.join("config","config.yml"))["features"]

  features.each do |name, controller_name, action_names, role_names|
    f = Feature.where(name: name).take
    if f
      if f.controller_name != controller_name || f.action_names != action_names || f.role_names != role_names
        puts "更新功能：#{name}，#{controller_name}，#{action_names}"
        f.update :controller_name => controller_name, :action_names => action_names, :role_names => role_names
      end
    else
      puts "新增功能：#{name}，#{controller_name}，#{action_names}, #{role_names}"
      Feature.create :name => name, :controller_name => controller_name, :action_names => action_names, :role_names => role_names
    end
  end

  Feature.all.each do |f|
    if features.select{ |ff| ff[0] == f.name }.empty?
      puts "删除功能 #{f.name}，#{f.controller_name}，#{f.action_names}"
      f.destroy
    end
  end

  puts "为系统内所有角色授权"
  # 删除所有旧的关联
  RoleFeature.delete_all
  # 为角色关联新的权限
  Feature.all.each do |f|
    role_names = f.role_names.split(',')

    if role_names.include? 'all'
      # 如果该角色适用于角色则为所有角色授权
      Role.all.each { |role| role.role_features.find_or_create_by(feature_id: f.id) }
    else
      # 如果不包含all则，针对对应的角色授权
      Role.where(name: role_names.map(&:strip).map(&:to_sym)).each { |role| role.role_features.find_or_create_by(feature_id: f.id) }
    end
  end
  puts "授权完成"
end
