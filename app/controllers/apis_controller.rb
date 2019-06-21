require 'jwt'
class ApisController < ApplicationController
	skip_before_action :can
	skip_before_action :authorize
	skip_before_action :verify_authenticity_token

	def register 
		if !User.where(:login=>params['login'],:mobile_phone=>params['phone'],:landline=>params['landline']).exists?
	    user = User.new(:login=>params['login'],:password => params['password'], :password_confirmation => params['password'],:mobile_phone=>params['phone'],:landline=>params['landline'])
	    org = Organization.where(:name=>params["organization"]).try(:first)
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
				json["msg"] = "注册并且上传正面相片失败"
				json["errors"] = user.errors.messages
				respond_to do |format|
					format.json { render json:json.to_json }
				end
			end
		else
			user = User.where(:login=>params['login'],:mobile_phone=>params['phone'],:landline=>params['landline']).first
			user.negative.attach params["negative"]
			json = {"code":"0","msg":"上传背面相片成功,注册结束","errors":{}}
			if user.save
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
		json = {"courts": Organization.where('name like ?', "%#{name}%").all.select(:name)}
		respond_to do |format|
			format.json { render json:json.to_json }
		end		
	end

	def get_search_centers
		name = params["name_str"]
		json = {"centers": Organization.where('name like ?', "%#{name}%").all.select(:name)}
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
		cases = MainCase.joins(:appraised_unit)
		if params["name"].present?
			cases = cases.where("name=?",params["name"])
		end
		if params["organization"].present?
			cases = cases.where(:organization_name => params["organization"])
		end
		if params["case_stage"].present?
			cases = cases.where(:case_stage => params["case_stage"])
		end

	  data = cases.map{|e| {"id": e.id, "time": e.created_at.strftime('%Y/%m/%d'),"case_stage": e.case_stage,"organization_name": e.organization_name,"anyou":e.anyou,"appraised_unit": e.appraised_unit}}

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
			"case_no":e.case_no,
			"case_stage":e.case_stage,
			"matter":e.matter,
			"time": e.created_at.strftime('%Y/%m/%d'),
			"anyou":e.anyou,
			"appraised_unit":e.appraised_unit,
			"entrust_people"=>(User.find_by(:id => e.wtr_id).present?)? User.find_by(:id => e.wtr_id).name: "",
			"organization_name"=>e.organization_name,
			"organization_phone"=>e.organization_phone
		}

		procress_data = e.case_process_records.map{|record| {"detail":record.detail,"created_at":record.created_at.strftime('%Y/%m/%d')}}
		json = {"code": "0","messages":"请求成功","data": {"case_data":case_data,"procress_data":procress_data}}
		respond_to do |format|
			format.json { render json:json.to_json }
	  end			
	end

  def get_case_talk
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])

		cases = MainCase.find_by(:id=>params["caseid"])
		if cases.blank?
			json = {"code": "1","messages":"未找到case"}
			respond_to do |format|
				format.json { render json:json.to_json }
		  end	
		else
			talks = cases.case_talks.map do |talk|
				is_me = (talk.user == user)? true : false
				{"time":talk.created_at.strftime('%Y/%m/%d'),"detail": talk.detail,"is_me":is_me,"talk_name":talk.user.name}
			end
			json = {"code": "0","messages":"请求成功","data": talks}
			respond_to do |format|
				format.json { render json:json.to_json }
		  end	 
		end
   	
  end 
end