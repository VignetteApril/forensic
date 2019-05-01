desc '导入省市区县数据'
task :import_area_data => :environment do
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

  puts '所有省市区初始化成功'
end