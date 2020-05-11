# {"id"=>1, "flow_no"=>"BJ2012010900001", "case_no"=>"京正2012临伤鉴字第1号", 
#   "devolve_name"=>"海淀交通支队公主坟大队", "city"=>110108, "accusers"=>"魏明", 
#   "appellees"=>"", "case_kind"=>1, "devolve_time"=>1325692800, "appellate_time"=>1325692800, 
#   "apprase_cyc"=>30, "link_man"=>"冯杨；白宇新", "link_tel"=>"010-82335886", "link_mobile"=>"13103245835", 
#   "consign_type"=>2, "devolve_caseno"=>"", "case_cause"=>2, "apprase_type"=>10, "apprase_details"=>"101", 
#   "by_apprase"=>2, "by_apprase_name"=>"魏明", "by_linkman"=>"魏明", "by_linktel"=>"15231491814", 
#   "appellate_state"=>1, "audit_user"=>"何新爱", "devolve_depart"=>2, "state"=>10, "state_time"=>0, 
#   "charge_state"=>0, "charge_total"=>0.0, "charge_appraise"=>0.0, "charge_payed"=>0.0, 
#   "charge_back"=>0.0, "uid"=>2, "efficient_time"=>1332037894, "dateline"=>1326087819, "payment_time"=>nil}

# id: 2, serial_no: "2020011622444644S", case_no_display: "XXX司鉴[2020]asds鉴字第112号", 
# user_id: nil, accept_date: nil, case_stage: "close", case_close_date: nil, case_type: "3213", 
# created_at: "2020-01-16 14:44:46", updated_at: "2020-01-16 15:33:25", user_name: "312321", 
# organization_name: "213123123", organization_id: nil, anyou: "交通事故", area_id: 15994, 
# organization_phone: nil, organization_addr: "231231", department_id: 1, matter: "[\"sda\"]", 
# matter_demand: "3123", base_info: "123123", pass_user: nil, sign_user: nil, supplement_date: nil, 
# case_property: "普通", commission_date: "2020-01-08 16:00:00", financial_stage: "unpaid", case_no: 112, 
# province_id: 15992, city_id: 15993, district_id: 15994, identification_cycle: nil, material_cycle: nil, 
# ident_users: nil, acceptance_date: nil, wtr_id: nil, payer: nil, payer_phone: nil, amount: nil, 
# wtr_phone: "213123", entrust_order_id: nil, filed_date: nil, appraisal_opinion: nil, original_appraisal_opinion: "", 
# is_repeat: false, archive_location: nil

desc '导入旧数据'
task :import_old_cases => :environment do
  department_map = {
    "临医" => "医疗损害责任室",
    "临伤" => "法医临床室",
    "文鉴" => "文检室",
    "痕鉴" => "痕迹鉴定室",
    "病鉴" => "法医病理室"
  }

  sql = "select * from cases_basic limit 1"
  begin
    result = ActiveRecord::Base.connection.execute(sql).to_a
    result.each do |basic_case|
      # 根据
      department_short_word = basic_case["case_no"].match(/[0-9].*鉴字/).to_s[4..5]
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