# -*- encoding : utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "设置系统管理员用户"
if User.find_by_login('admin').nil?
  user = User.create login: 'admin', name: "系统管理员", email: 'admin@audit.gov.cn',
                     password: '123456@Shike', password_confirmation: '123456@Shike'
else
  user = User.find_by_login('admin')
end

puts "设置系统管理员角色"
role = Role.find_or_create_by name: '系统管理员'

puts "关联系统管理员角色和用户"
UserRole.find_or_create_by user_id: user.id, role_id: role.id

puts "初始化所有的系统功能"
Feature.delete_all
features = YAML.load_file(Rails.root.join("config","config.yml"))["features"]

features.each do |name, controller_name, action_names, app|
  Feature.create :app => app, :name => name, :controller_name => controller_name, :action_names => action_names
  puts 'feature: ' << name
end

puts "为系统管理员授权"
Feature.all.each do |f|
  role.role_features.find_or_create_by(feature_id: f.id)
end

puts "初始化地区信息表"
file = File.read(Rails.root.join("public", "geo/city_list.json"))
data = JSON.parse(file)

data.each do |province_data|
  province = Area.create(name: province_data['name'], code: province_data['code'], area_type: :province)

  next if province_data['cityList'].nil?
  province_data['cityList'].each do |city_data|
    city = province.children.create(name: city_data['name'], code: city_data['code'], area_type: :city, parent_id: province.id)
    puts "创建了省#{province.name}中的#{city.name}市"

    next if city_data['areaList'].nil?
    city_data['areaList'].each do |district_data|
      district = city.children.create(name: district_data['name'], code: district_data['code'], area_type: :district, parent_id: city.id)
      puts "创建了#{city.name}市中的#{district.name}区"
    end
  end
end

puts "初始化系统配置参数"
SysConfig.find_or_create_by gem: '平台', key: 'SUPER_ROLES', value: '系统管理员', desc: '系统超级用户的角色名称，使用英文逗号分隔（例如：系统管理员）'
SysConfig.find_or_create_by gem: '平台', key: 'DEPARTMENT_ONLYLEAF_CAN_HAS_USER', value: '是', desc: '组织结构中是否只有叶子节点可以拥有用户？（填写：是 / 否）'
SysConfig.find_or_create_by gem: '平台', key: 'ACCOUNTING_LEVEL', value: '本级', desc: '核算级次（行政区划/所属机构）名称，使用英文逗号分隔（例如：本级,和平区,南开区）'
SysConfig.find_or_create_by gem: '平台', key: 'CUSTOMER_CODE', value: 'SHIKEDEMO', desc: '客户标识，与授权码匹配，根据授权码所对应的客户标识代码填写'
SysConfig.find_or_create_by gem: '平台', key: 'SYS_TITLE', value: '司法鉴定', desc: '显示在页面标题栏的系统名称'
SysConfig.find_or_create_by gem: '平台', key: 'SYS_SUBTITLE', value: '司法鉴定系统', desc: '显示在页面标题栏的系统名称'
SysConfig.find_or_create_by gem: '平台', key: 'LIBREOFFICE_DIR', value: '/use/lib/libreoffice/program/soffice', desc: 'LibreOffice软件的路径地址<br>MacOS: /Applications/LibreOffice.app/Contents/MacOS/soffice<br>CentOS: /usr/lib64/libreoffice/program/soffice<br>Ubuntu: /usr/lib/libreoffice/program/soffice'
SysConfig.find_or_create_by gem: '平台', key: 'SYS_LOGO', value: 'logo.png', desc: '系统LOGO图标文件地址'
