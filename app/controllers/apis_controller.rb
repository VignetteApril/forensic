require 'jwt'
require "net/http" 

class ApisController < ApplicationController
	include ActionView::Helpers::DateHelper

	skip_before_action :can
	skip_before_action :authorize
	skip_before_action :verify_authenticity_token

	before_action :set_token, only: [:get_notice_list_by_case_id, :get_notice_list_by_serise_no]

	def wx_msg_code_to_session
		# code2Session
		app_id = "wx5e9e5d5e051dcd16"
		secret = "370a22bff4b187b86aed5158489ff671"
		jscode = params["jscode"]

		url  = URI("https://api.weixin.qq.com/sns/jscode2session?appid=#{app_id}&secret=#{secret}&js_code=#{jscode}&grant_type=authorization_code")
		res  = Net::HTTP.get_response(url)

		respond_to do |format|
			format.json { render json:res.body }
		end
	end

	def wx_msg_send(form_id,tem_id,data)
		app_id = "wx5e9e5d5e051dcd16"
		secret = "370a22bff4b187b86aed5158489ff671"

		token_url  = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{app_id}&secret=#{secret}")
		token_res  = Net::HTTP.get_response(token_url)
		token = JSON.parse(token_res.body)["access_token"].to_s

		# msg_url = URI("https://api.weixin.qq.com/cgi-bin/message/wxopen/template/send?access_token=#{token}")
		# data = {
  #     "keyword1": {
  #         "value": "创建委托单成功！"
  #     },
  #     "keyword2": {
  #         "value": "#{Time.now.strftime('%Y-%m-%d')}"
  #     },

		# res = Net::HTTP.post_form(msg_url, 'touser' => params['touser'], 'template_id' => tem_id, 'form_id' => form_id)
  #   p "发送通知"
 	# 	p res.body 
	end


	def register 
		wtr_role = Role.where(name:'client_entrust_user').first
		province_id = Area.find(params["city_id"]).parent.id
		# 分两次提交图片请求，通过params判断是不是一个user
		if !User.where(:login=>params['login'],:mobile_phone=>params['phone'],:landline=>params['landline'],:name=>params['name']).exists?
	    user = User.new(:confirm_stage=>:not_confirm,:login=>params['login'],:form_id=>params['form_id'],:open_id=>params['open_id'],:name=>params['name'],:password => params['password'], :password_confirmation => params['password'],:mobile_phone=>params['phone'],:landline=>params['landline'])
	
	    org = Organization.where(:name=>params["organization"]).try(:first)
	    if Organization.where(:name =>params["organization"]).exists?
	    	org = Organization.where(:name =>params["organization"]).first
	    else
	    	org = Organization.new(is_confirm:false,name: params["organization"],org_type: :court,:province_id=>province_id,:city_id=>params['city_id'].to_i, :district_id=>params['district_id'].to_i,:area_id=>params['district_id'].to_i)
	    	unless org.save
	    		json = {"code":"0","msg":"关联新创建的法院失败"}				
		    	respond_to do |format|
						format.json { render json:json.to_json }
					end
	    	end
	    end

	    user.organization = org
	    dep = org.departments.where(:name=>params["department"]).try(:first)
	    if dep.nil?
	    	dep = org.departments.create(:name=>params["department"])
	    	p "没找到#{org.name}下的部门#{params["department"]} 创建----#{dep.save}"
	    end
	    user.departments = dep.id.to_s

	    user.positive.attach params["positive"]
			json = {"code":"0","msg":"注册并且上传正面相片成功","errors":{}}
			if user.save
				respond_to do |format|
					format.json { render json:json.to_json }
				end
			else
				json["code"] = "1"
				json["msg"] = "提交注册信息并且上传正面相片失败"
				json["errors"] = user.errors.full_messages
				respond_to do |format|
					format.json { render json:json.to_json }
				end
			end
		else
			user = User.where(:login=>params['login'],:mobile_phone=>params['phone'],:landline=>params['landline']).first
			user.negative.attach params["negative"]
			json = {"code":"0","msg":"上传背面相片成功,提交注册信息成功","errors":{}}
			if user.save
				wtr_role.user_roles.find_or_create_by user_id: user.id, role_id: wtr_role.id
				respond_to do |format|
					format.json { render json:json.to_json }
				end
			else
				json["code"] = "1"
				json["msg"] = "上传背面相片失败"
				json["errors"] = user.errors.messages
				respond_to do |format|
					format.json { render json:json.to_json }
				end
			end			
		end
	end

	def get_search_courts
		name = params["name_str"]
		json = {}
		json["code"] = "0"
		json["data"] = {"courts": Organization.where('name like ?', "%#{name}%").where(:org_type=>:court).all.select(:name,:id)}
		respond_to do |format|
			format.json { render json:json.to_json }
		end		
	end

	def get_search_centers
		name = params["name_str"]
		json = {}
		json["code"] = "0"
		json["data"] = {"centers": Organization.where('name like ?', "%#{name}%").where(:org_type=>:center).all.select(:name,:id)}
		respond_to do |format|
			format.json { render json:json.to_json }
		end				
	end

	def login
		user = User.authenticate(params["login"], params["password"])
		json = {"code":"0","msg":"login_success","token":""}
		if user.nil?
			json["msg"] = "login_failed"
			json["code"] = "1"
		  respond_to do |format|
				format.json { render json:json.to_json }
			end		
		elsif !user.confirm?
			json["msg"] = "此账号在审核中未开通权限"
			json["code"] = "1"
		  respond_to do |format|
				format.json { render json:json.to_json }
			end	
		else
			user_info = {"id":user.id,"login":user.login}
			user_token = JWT.encode user_info, nil, 'none'
      json["token"]= user_token
      respond_to do |format|
				format.json { render json:json.to_json }
			end
		end		
	end

	def get_user_infos
		decoded_token = JWT.decode params[:token], nil, false
		user  = User.find_by(:id=>decoded_token[0]["id"])

		total_count = MainCase.where(:wtr_id=>user.id).count
		executing_count = MainCase.where(:wtr_id=>user.id,:case_stage=>:executing).count
		close_count = MainCase.where(:wtr_id=>user.id,:case_stage=>:close).count
		rejected_count = MainCase.where(:wtr_id=>user.id,:case_stage=>:rejected).count

		json = {
			"code": "0",
    		"message": "成功",
		    "data":{
		    	"name":user.name,  
			    "organization":user.organization,
			    "department":user.department_names, 
			    "phone":user.mobile_phone,  
			    "landline":user.landline,
			    "address":user.address, 
			    "caseProgressNumber":total_count, 
			    "caseFinishNumber":close_count,  
			    "caseLoadingNumber":executing_count, 
		    	"casePCancleNumber":rejected_count
			}
		}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end
	end

	def update_user_infos
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])

		org = Organization.where(:name=>params["organization"]).try(:first)
		if org.nil?
			org = Organization.create(:name=>params["organization"],:org_type=>:court,:province_id=>user.organization.province_id,:city_id=>user.organization.city_id,:district_id=>user.organization.district_id,:area_id=>user.organization.area_id)
		end
		user.organization = org

		dep = org.departments.where(:name=>params["department"]).try(:first)
        if dep.nil?
        	dep = org.departments.create(:name=>params["department"])
        end
        user.departments = dep.id.to_s
        user.name = params["name"]
        user.mobile_phone = params["phone"]
        user.landline = params["landline"]
        user.address = params["address"]

		json = {"code":"0","msg":"update_success","errors":{}}
		if user.save
			respond_to do |format|
				format.json { render json:json.to_json }
			end
		else
			json["code"] = "1"
			json["msg"] = "update_failed"
			json["errors"] = user.errors.messages
			respond_to do |format|
				format.json { render json:json.to_json }
			end
		end	
	end

	def get_city_list
		json = {"code": "0","messages":"请求成功","data":Area.roots.map(&:children).flatten.map{|e| {"id":e.id,"name":e.name}}}
		respond_to do |format|
			format.json { render json:json.to_json }
	  end
	end

	def get_district_list
		json = {"code": "0","messages":"请求成功","data":Area.where(:name=> params['city'],:area_type=>"city").first.children.map{|e| {"id":e.id,"name":e.name}}}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end		
	end

	def get_case_notice_list
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		notifications = user.notifications
		if !params[:case_id].blank?
			notifications = notifications.where(:main_case_id => params[:case_id]).order("created_at desc")
		end
		data = notifications.map{|e| e.infos_for_api}

		json = {"code": "0","messages":"请求成功","data":data}
		respond_to do |format|
			format.json { render json:json.to_json }
	  end
	end

	def get_notice_list
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		notifications = user.notifications
		data = {}
		data["true"] = []
		data["false"] =[]
		notifications.each do |n|
			data["#{n.status}"].push(n.infos_for_api)
		end
		json = {"code": "0","messages":"请求成功","data":data}
		respond_to do |format|
			format.json { render json:json.to_json }
	  end				
	end

	# 按照案件分组的消息接口
	def get_notice_list_by_serise_no
		notifications = @user.notifications
		data = {}
		data["true"] = []
		data["false"] =[]
		notifications.each do |n|
			data["#{n.status}"].each do |sub_no|
				if n.main_case.id == sub_no["case_id"]
					sub_no[:total_num] += 1
				else
					data["#{n.status}"].push(n.infos_for_api.merge({ total_num: 0 }))
				end
			end
		end

		json = {"code": "0","messages":"请求成功","data":data}
		respond_to do |format|
			format.json { render json:json.to_json }
		end
	end

	# 点击某个分组进入到某个案件消息的列表
	def get_notice_list_by_case_id
		notifications = @user.notifications
		if !params[:case_id].blank?
			notifications = notifications.where(:main_case_id => params[:case_id]).order("created_at desc")
		end

		data = {}
		data["true"] = []
		data["false"] =[]
		notifications.each do |n|
			data["#{n.status}"].push(n.infos_for_api)
		end

		# 如果是在未读的标签则更新未读的消息状态为已读
		if params[:read] == 'false'
			notifications.where(status: false).update(status: true)
		end

		json = {"code": "0","messages":"请求成功","data":data}
		respond_to do |format|
			format.json { render json:json.to_json }
		end
	end

	def change_notice_status
		n = Notification.find_by(:id=>params[:id])
		n.status = true
		if n.save
			respond_to do |format|
				format.json { render json:{"code": "0","messages":"修改成功"}.to_json }
		  end	
		else
			respond_to do |format|
				format.json { render json:{"code": "1","messages":"修改失败"}.to_json }
		  end	
		end
	end

	def get_case_list
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])

		cases = MainCase.joins(:appraised_unit).where(:wtr_id=>user.id)
		if params["name"].present?
			cases = cases.where("name=?",params["name"])
		end
		# 案件三重搜索里搜索鉴定中心为xxx的案件
		if params["organization_id"].present?
			cases = cases.where(:organization_id => params["organization_id"])
		end
		if params["case_stage"].present?
			cases = cases.where(:case_stage => params["case_stage"])
		end

	  data = cases.map{|e| {"id": e.id, "time": e.created_at.strftime('%Y/%m/%d'),"case_stage": e.case_stage,"center_name": Organization.find_by(:id=>e.organization_id).try(:name),"anyou":e.anyou,"appraised_unit": e.appraised_unit}}

		json = {"code": "0","messages":"请求成功","data": data}
		respond_to do |format|
			format.json { render json:json.to_json }
	  end	
	end

	def get_case_detail_progress
		e = MainCase.find_by(:id=>params[:caseid])
		if e.blank?
			json = {"code": "1","messages":"案件id错误"}
			respond_to do |format|
				format.json { render json:json.to_json }
		  end
		  return
		end

		case_data = {
			"id": e.id,
			"case_code":e.serial_no,
			"case_stage":e.case_stage,
			"matter":e.matter,
			"time": e.created_at.strftime('%Y-%m-%d'),
			"anyou":e.anyou,
			"appraised_unit":e.appraised_unit,
			ident_users: User.where(id: e.ident_users).map(&:name).join(','),
			pass_user: User.find(e.pass_user).try(:name),
			filed_date: e.filed_date.strftime("%Y年 %m月 %d日"),
			distance_of_time: get_distance_of_time(e),
			"entrust_people"=>(User.find_by(:id => e.wtr_id).present?)? User.find_by(:id => e.wtr_id).name: "",
			"organization_name"=>e.organization_name,
			"organization_phone"=>e.organization_phone
		}

		procress_data = e.case_process_records.map{|record| {"detail":record.detail,"created_at":record.created_at.strftime('%Y-%m-%d')}}
		json = {"code": "0","messages":"请求成功","data": {"case_data":case_data,"procress_data":procress_data}}
		respond_to do |format|
			format.json { render json:json.to_json }
	  end			
	end

  #创建被鉴定人
  def create_appraised_unit
  	decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		birthday = params["birthday"].blank? ? nil : Date.parse(params["birthday"])
		unit = AppraisedUnit.new(:unit_type=>params["unit_type"],:mobile_phone=>params["mobile_phone"],:unit_contact=>params["unit_contact"],:name=>params["name"],:gender=>params["gender"],:birthday=>birthday,:id_type=>params["id_type"],:id_num=>params["id_num"],:addr=>params["addr"])
    unit.wtr_id = user.id
    if unit.save
	    respond_to do |format|
				format.json { render json:{"code": "0","messages":"注册被鉴定人成功","unit_id":unit.id}.to_json }
		  end	
		else
			respond_to do |format|
				format.json { render json:{"code": "1","messages":"注册被鉴定人失败"}.to_json }
		  end	
		end
  end
  #返回当前被鉴定人列表（当前委托人曾经建立的所有的被鉴定人列表）
  def get_appraised_unit
  	decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])    
    units = AppraisedUnit.where(:wtr_id=>user.id).exists? ? AppraisedUnit.where(:wtr_id=>user.id) : []
  	respond_to do |format|
			format.json { render json:{"code": "0","data"=>units}.to_json }
	  end	
  end

  #创建委托单
  def create_entrust_order
  	decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])  	
  	entrust_order = EntrustOrder.new(:case_property=>params["case_property"],
                                     :matter_demand=>params["matter_demand"],
                                     :base_info=>params["base_info"],
                                     :anyou=>params["anyou"],
                                     matter: params[:matter].split(','))
  	entrust_order.organization_id = params["organization_id"]
  	entrust_order.user = user
  	entrust_order.entrust_doc.attach params["entrust_doc"]
  	#必须要先save不然entrust_order.appraised_unit 使用 EntrustOrder.last.appraised_unit读取会发现没有持久化传入的被鉴定人却绑定了一个空的新的被鉴定人
  	entrust_order.save
		entrust_order.build_appraised_unit(unit_type: params[:unit_type].to_i, name: params[:name])

    if entrust_order.save
    	# wx_msg_send(params["form_id"])
	    respond_to do |format|
				format.json { render json:{"code": "0","messages":"创建委托单成功"}.to_json }
		  end	
		else
			respond_to do |format|
				format.json { render json:{"code": "1","messages":"创建委托单失败"}.to_json }
		  end	
		end  	
  end

  def departments_through_org_id
    organization = Organization.find_by_id params[:id]

    if organization.present?
      data = organization.departments.map do |department|
        { name: department.name, id: department.id }
      end
      message = '请求接口成功！'
      code = 0
    else
      data = []
      message = '没找到对应的机构！'
      code = 1
    end

    respond_to do |format|
      format.json { render json:{ code: code, messages: message, data: data }.to_json }
    end
  end

  def matter_through_dep_id
    department = Department.find_by_id params[:id]

    if department.present?
      data = department.matter.empty? ? [] : department.matter.split(',')
      message = '请求接口成功！'
      code = 0
    else
      data = []
      message = '没找到对应的科室！'
      code = 1
    end

    respond_to do |format|
      format.json { render json:{ code: code, messages: message, data: data }.to_json }
    end
  end

  #查看委托人下的所有案件的鉴定中心的集合
  def get_entrust_orgs
  	decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])

		organization_ids = MainCase.where(:wtr_id=>user.id).map{|e|e.department.organization.id}.compact
		orgs_hash =[]
		organization_ids.each do |id|
			orgs_hash << {"center_name": Organization.find_by(:id=>id).name, "id":id}
		end

		respond_to do |format|
			format.json { render json:{"code": "0","messages":"查询成功","data": orgs_hash}.to_json }
	  end	

  end

  #发送会话
  def create_talk
  	decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		my_case = MainCase.find_by(:id=>params["caseid"])

		@case_memo = my_case.case_memos.new({ content: params["detail"], visibility_range: :all_user })
		@case_memo.user = user

    if @case_memo.save
	    respond_to do |format|
				format.json { render json:{"code": "0","messages":"发送消息成功"}.to_json }
		  end	
		else
			respond_to do |format|
				format.json { render json:{"code": "1","messages":"发送消息失败"}.to_json }
		  end	
		end  			
	end

	# 获取对话信息
	def get_case_talk
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		if user.blank?
			json = {"code": "1","messages":"根据token找不到用户"}
			respond_to do |format|
				format.json { render json:json.to_json }
			end
		else
			@main_case = MainCase.find_by(:id=>params["caseid"])
			@case_memos = if @main_case.temp_ident_user?(user)
											@main_case.case_memos.where.not(visibility_range: :only_me)
										elsif @main_case.wtr?(user)
											@main_case.case_memos.where(visibility_range: [:current_case, :current_case_and_leader])
										elsif user.center_department_director_user?
											@main_case.case_memos.where(visibility_range: :current_case_and_leader)
										else
											MainCase.none
										end.or(@main_case.case_memos.where(user_id: user.id)).or(@main_case.case_memos.where(visibility_range: :all_user)).order(:created_at).uniq


			if @main_case.blank?
				json = {"code": "1","messages":"未找到case"}
				respond_to do |format|
					format.json { render json:json.to_json }
				end
			else
				memos = @case_memos.map do |memo|
					is_me = (memo.user == user)? true : false
					{ time: memo.created_at.strftime('%Y/%m/%d'), detail: memo.content, is_me: is_me, talk_name: memo.try(:user).try(:name), tail_user_id: memo.try(:user).try(:id) }
				end
				json = {"code": "0","messages":"请求成功","data": memos}
				respond_to do |format|
					format.json { render json: json.to_json }
				end
			end
		end

	end

	private
		def get_distance_of_time(main_case)
			case main_case.case_stage.to_sym
			when :pending
				'距离登记已过' + distance_of_time_in_words(Time.now, main_case.created_at, scope: 'datetime.distance_in_words')
			when :add_material
				if main_case.material_cycle.nil?
					'请选择补充材料周期'
				else
					date_bool = Time.now <=> (main_case.created_at + main_case.material_cycle.days)
					date_pre_str = date_bool > 0 ?  '距补充材料规定日期已过' : '距离补充材料到期还剩'
					date_distance = distance_of_time_in_words(Time.now, main_case.created_at + main_case.material_cycle.days, scope: 'datetime.distance_in_words')
					if date_bool
						date_pre_str + date_distance
					else
						date_pre_str + date_distance
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
						date_pre_str + date_distance
					else
						date_pre_str + date_distance
					end
				end
			end
		end

		def set_token
			@decoded_token = JWT.decode params[:token], nil, false
			@user = User.find_by(:id=>@decoded_token[0]["id"])
		end
end