require 'jwt'
class ApisController < ApplicationController
	skip_before_action :can
	skip_before_action :authorize
	skip_before_action :verify_authenticity_token

	def register 
		province_id = Area.find(params["city_id"]).parent.id
        user = User.new(:login=>params['name'],:password => params['password'], :password_confirmation => params['password'],:province_id=>province_id,:city_id=>params['city_id'].to_i, :district_id=>params['district_id'].to_i,:mobile_phone=>params['phone'],:landline=>params['landline'])

        org = Organization.where(:name=>params["organization"]).try(:first)
        if org.nil?
        	org = Organization.create(:name=>params["organization"],:org_type=>:court,:province_id=>province_id,:city_id=>params['city_id'].to_i, :district_id=>params['district_id'].to_i,:area_id=>params['district_id'].to_i)
        	p "没找到机构#{params["organization"]} 创建----#{org.save}"
        end        
        user.organization = org

        dep = org.departments.where(:name=>params["department"]).try(:first)
        if dep.nil?
        	dep = org.departments.create(:name=>params["department"])
        	p "没找到#{org.name}下的部门#{params["department"]} 创建----#{dep.save}"
        end
        user.departments = dep.id.to_s

        user.positive.attach params["positive"]
        user.negative.attach params["negative"]

		json = {"code":"0","msg":"register_success","errors":{}}
		if user.save
			respond_to do |format|
				format.json { render json:json.to_json }
			end
		else
			json["code"] = "1"
			json["msg"] = "register_failed"
			json["errors"] = user.errors.messages
			respond_to do |format|
				format.json { render json:json.to_json }
			end
		end
	end

	def login
		user = User.authenticate(params["name"], params["password"])
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
		json = {"code": "0","messages":"请求成功","data":user.notifications.map(&:infos_for_api)}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end				
	end

	def get_case_list
		# decoded_token = JWT.decode params[:token], nil, false
		# user = User.find_by(:id=>decoded_token[0]["id"])	
		cases = MainCase.where(:organization_name => params["organization"] , :case_stage => params["case_stage"] )
	    # cases = MainCase.where(:case_stage => params["case_stage"])
	    data = cases.map{|e| {"id": e.id, "time": e.created_at.strftime('%Y/%m/%d'), "anyou":e.anyou,"appraised_unit": e.appraised_unit}}

		json = {"code": "0","messages":"请求成功","data": data}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end	
	end

	def get_case_detail_progress
		# decoded_token = JWT.decode params[:token], nil, false
		# user = User.find_by(:id=>decoded_token[0]["id"])
		e = MainCase.find_by(:id=>params[:caseid])
		case_data = {
			"id": e.id,
			"matter":e.matter,
			"time": e.created_at.strftime('%Y/%m/%d'),
			"anyou":e.anyou,
			"appraised_unit":e.appraised_unit,
			"principal_people"=>User.find_by(:id => e.wtr_id).name,
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
		talks = MainCase.find_by(:id=>params["caseid"]).case_talks.map do |talk|
			is_me = (talk.user == user)? true : false
			{"time":talk.created_at.strftime('%Y/%m/%d'),"detail": talk.detail,"is_me":is_me}
		end
		json = {"code": "0","messages":"请求成功","data": talks}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end	    	
    end 
end