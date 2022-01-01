desc '导入旧数据'
task :import_old_cases => :environment do
  department_map = {
    "临医" => "医疗损害责任室",
    "临伤" => "法医临床室",
    "文鉴" => "文检室",
    "痕鉴" => "痕迹鉴定室",
    "病鉴" => "法医病理室"
  }

  sql = "select * from cases_basic"
  begin
    result = ActiveRecord::Base.connection.execute(sql).to_a
    result.each do |basic_case|
      # 根据
      temp_case_string = basic_case["case_no"].match(/[0-9].*鉴字/).to_s
      year = temp_case_string[0..3]
      next if year != '2018'
      department_short_word = temp_case_string[4..5]
      department_name = department_map[department_short_word]
      department = Department.find_by(name: department_name)
      
      if department.nil?
        puts "找不到科室！"
        next
      else
        puts "当前科室：#{department.name}"
      end

      serial_no = basic_case["flow_no"]
      organization_name = basic_case["devolve_name"]
      user_name = basic_case["link_man"]
      organization_phone = basic_case["link_tel"]
      by_apprase_name = basic_case["by_apprase_name"]
      main_case = MainCase.create!(serial_no: serial_no, 
                                   organization_name: organization_name, 
                                   department_id: department.id, 
                                   user_name: user_name, 
                                   organization_phone: organization_phone, 
                                   province_id: 12801, 
                                   city_id: 12802, 
                                   district_id: 12803,
                                   matter: "[\"test\"]")
      AppraisedUnit.create!(name: by_apprase_name, main_case_id: main_case.id)
    end
  rescue Exception => e
    puts e.to_s
  end
end