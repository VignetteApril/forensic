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
  user = User.create login: 'admin', name: "系统管理员", email: 'admin@forensic.com',
                     password: 'Fc123456', password_confirmation: 'Fc123456'
else
  user = User.find_by_login('admin')
end

puts "设置系统管理员角色"
role = Role.find_or_create_by name: :admin_user, r_type: :platform

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

puts "设置管理员以外的角色"
Role::NAME_TYPE.each do |key, value|
  puts "设置角色#{value}"
  r_type = key == :client_entrust_user ? :court : :center
  Role.find_or_create_by name: key.to_sym, r_type: r_type
end


puts "初始化地区信息表"
# 清空地区信息表
Area.delete_all

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