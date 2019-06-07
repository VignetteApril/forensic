require 'jwt'
class ApisController < ApplicationController
	skip_before_action :can
	skip_before_action :authorize
	skip_before_action :verify_authenticity_token

	def register 
	#TODO 地域 单位 email 新加字段等问题  
        user = User.new(:login=>params['name'],:password => params['password'], :password_confirmation => params['password'],:email=>params['email'])

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
		#TODO MainCase enum?
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		respond_to do |format|
			format.json { render json:user.to_json }
	    end
	end

	def updata_user_infos
		#TODO 地域 单位 email 新加字段等问题  
	end

	def get_city_list
		json = {"code": "0","messages":"请求成功","data":Area.roots.map(&:children).flatten.map(&:name)}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end
	end

	def get_district_list
		json = {"code": "0","messages":"请求成功","data":Area.where(:name=> params['city'],:area_type=>"city").first.children.map(&:name)}
		respond_to do |format|
			format.json { render json:json.to_json }
	    end		
	end

	def get_notice_list
		#TODO 通知模型
		decoded_token = JWT.decode params[:token], nil, false
		user = User.find_by(:id=>decoded_token[0]["id"])
		binding.pry
	end

	def get_case_list

	end

	def get_case_detail_progress

	end

    def get_case_talk
    	
    end 
end