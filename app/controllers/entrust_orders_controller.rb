class EntrustOrdersController < ApplicationController
  layout 'system'
  before_action :set_anyou_and_case_property, only: [:new]

	def new
		@entrust_order = EntrustOrder.new
		@entrust_order.build_appraised_unit
		# TODO暂时用court以后改回center
		@center_collection = Organization.where(:org_type=>:court).map{|e| [e.name,e.id]}
	end

	def create
		@entrust_order = EntrustOrder.new(entrust_order_params)
		@entrust_order.user = @current_user

		respond_to do |format|
			if @entrust_order.save
	      format.html { redirect_to new_entrust_order_url, notice: 'entrustorder was successfully create.' }
	      format.json { render :show, status: :ok, location: @entrust_order }
	    else
	      format.html { render :new }
	      format.json { render json: @entrust_order.errors, status: :unprocessable_entity }
	    end
  	end
	end

	private

	  def set_anyou_and_case_property
      @anyou = ANYOU.map { |anyou| [ anyou, anyou ] }
      @case_property = CASE_PROPERTY.map{ |case_property| [case_property, case_property] }
    end

    def entrust_order_params
    	params.require(:entrust_order).permit(:anyou,
																		    		:case_property,
																		    		:matter_demand,
																		    		:base_info,
																		    		:organization_id,
		                                        appraised_unit_attributes: [:id,
                                                                :unit_type,
                                                                :name,
                                                                :addr,
                                                                :gender,
                                                                :birthday,
                                                                :id_type,
                                                                :id_num,
                                                                :_destroy])
    end

end