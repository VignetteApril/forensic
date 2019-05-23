# -*- encoding : utf-8 -*-
class FeaturesController < ApplicationController
  layout 'system'
  before_action :set_role, only: [:add_features, :add_features_submit, :remove_feature_from_role]
  after_action :make_log, only: [:add_features_submit, :remove_feature_from_role]
  
  # 列出所有的系统功能列表
  def list
    @features = Feature.all.order("app,controller_name")
  end
  
  # 显示角色列表页面，默认显示所有系统角色，并且不需要分页显示
  # 同时针对每一个已有的角色，系统还需要显示“功能”链接。
  def index
    if (SysConfig.super_roles & @current_user.roles.map{ |r| r.name }).empty?
      @roles = Role.where(orgnization_name: [@current_user.orgnization_name, '系统'])
    else
      @roles = Role.all
    end
    # @roles = Role.all
    @role = params[:role_id] ? Role.find_by_id(params[:role_id]) : @roles.first
    @features = initialize_grid(@role.features, name: 'role_features', per_page: 1000)
  end

  # 管理员在角色授权列表页面中，点击 “授权”按钮,系统显示所有功能的列表
  def add_features
    @features = initialize_grid(Feature, name: 'features', per_page: 1000)
  end
  
  # 管理员通过名称的关键字模糊搜索对列表进行过滤，
  # 然后选择某一个功能，点击“加入”按钮，系统将该功能加入该角色，并返回角色授权列表页面。
  def add_features_submit
    if params[:features] && params[:features][:selected]
      @selected = params[:features][:selected]
      @selected.each do |fid|
        @role.role_features.find_or_create_by feature_id: fid, role_id: @role.id
      end
    end
    redirect_to features_path(role_id: @role.id), notice: "新的权限已经加入了该角色！"
  end
  
  # 管理员在角色对应权限列表页面中，针对某一个功能点击“移除”按钮，
  # 系统在要求管理员确认之后，将该功能移出该角色，并返回角色授权列表页面。
  def remove_feature_from_role 
    @role.role_features.where(feature_id: params[:feature_id]).take.destroy
    # @role = Role.find(params[:role_id])
    @features = initialize_grid(@role.features, name: 'role_features')
    respond_to do |format|
      # format.html { render :role_features_grid }
      format.html { redirect_to features_path(role_id: @role.id) }
      format.js
    end
  end
  
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_role
    @role = Role.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def role_params
    params.require(:role).permit(:name, :description)
  end
end
