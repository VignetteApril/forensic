class AreasController < ApplicationController
  skip_before_action :can
  skip_before_action :authorize

  def cities
    @cities = Area.find(params[:id]).children

    respond_to do |format|
      format.json
    end
  end

  def districts
    @districts = Area.find(params[:id]).children

    respond_to do |format|
      format.json
    end
  end

  def provinces
    @provinces = Area.roots

    respond_to do |format|
      format.json
    end
  end
end
