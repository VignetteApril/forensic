# -*- encoding : utf-8 -*-
class FavoritesController < ApplicationController
  skip_before_action :can, only: [:create, :update, :destroy]
  after_action :make_log, only: [:update, :create]
  
  # 增加收藏
  def create
    @favorite = @current_user.favorites.build(favorite_params)
    @favorite.save
    respond_to do |format|
      format.html
      format.js
    end
  end

  # 更新收藏信息
  def update
    @favorite = Favorite.find(params[:id])
    @favorite.update(favorite_params)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  # 删除收藏
  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  private

  def favorite_params
    params.require(:favorite).permit(:title, :url)
  end
end
