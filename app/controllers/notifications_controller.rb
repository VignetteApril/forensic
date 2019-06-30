# -*- encoding : utf-8 -*-
class NotificationsController < ApplicationController
  skip_before_action :can, only: [:all_readed]
  # 用户查看自己所有的个人事务提醒列表
  def index
    init_bread('个人事务提醒')
    @notifications = initialize_grid( Notification.where(user_id: @current_user&.id),       
                              order: 'created_at',
                              order_direction: 'desc',
                              per_page: 10, 
                              name: 'notifications')
  end
  
  # 标记提醒为已读并转向原始地址
  def show
    @notification = Notification.find(params[:id])
    if @notification
      @notification.update(status: "已读")
      redirect_to @notification.url
    end
  end
  
  # 直接标记某一个提醒为已读
  def edit
    @notification = Notification.find(params[:id])
    if @notification
      @notification.update(status: true)
      redirect_to notifications_path
    end
  end

  def all_readed
    errors = []
    @current_user.notifications.where(:status=>false).each do |notification|
      notification.status = true
      unless notification.save
        errors << notification.errors
      end
    end
    if errors.blank?
      respond_to do |format|
        format.json { render json:{:msg=>'全部设置已读成功'}.to_json }
      end
    else
      respond_to do |format|
        format.json { render json:{:msg=>'全部设置已读失败'}.to_json }
      end
    end
  end

end
