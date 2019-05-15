class MainCasesController < ApplicationController
  before_action :set_main_case, only: [:show, :edit, :update, :destroy]
  before_action :set_provinces, only: [:new, :edit, :organization_and_user, :create]
  before_action :set_court_users, only: [:new, :edit, :create]
  before_action :set_anyou_and_case_property, only: [:new, :edit, :create]
  before_action :set_department_matters, only: [:edit, :update]

  # GET /main_cases
  # GET /main_cases.json
  def index
    @main_cases = initialize_grid(MainCase, per_page: 20, name: 'main_cases_grid')
  end

  # GET /main_cases/1
  # GET /main_cases/1.json
  def show
    @area_name = Area.find(@main_case.area_id).display_name
  end

  # GET /main_cases/new
  def new
    @main_case = MainCase.new
    @main_case.transfer_docs.build
    @main_case.build_appraised_unit
  end

  # GET /main_cases/1/edit
  def edit
  end

  # POST /main_cases
  # POST /main_cases.json
  def create
    @main_case = MainCase.new(main_case_params)
    @main_case.area_id = _area_id(main_case_params[:province_id],
                                  main_case_params[:city_id],
                                  main_case_params[:district_id])
    respond_to do |format|
      if @main_case.save
        format.html { redirect_to @main_case, notice: 'Main case was successfully created.' }
        format.json { render :show, status: :created, location: @main_case }
      else
        format.html { render :new }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /main_cases/1
  # PATCH/PUT /main_cases/1.json
  def update
    @main_case.area_id = _area_id(main_case_params[:province_id],
                                  main_case_params[:city_id],
                                  main_case_params[:district_id])

    respond_to do |format|
      if @main_case.update(main_case_params)
        format.html { redirect_to @main_case, notice: 'Main case was successfully updated.' }
        format.json { render :show, status: :ok, location: @main_case }
      else
        format.html { render :edit }
        format.json { render json: @main_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /main_cases/1
  # DELETE /main_cases/1.json
  def destroy
    @main_case.destroy
    respond_to do |format|
      format.html { redirect_to main_cases_url, notice: 'Main case was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def organization_and_user
    user = User.find(params[:user_id])

    case user.organization.area.area_type.to_sym
    when :district
      @current_province = user.organization.area.root
      @current_city = user.organization.area.parent
      @current_district = user.organization.area
      @cites = @current_province.children
      @districts = @current_city.children
    when :city
      @current_province = user.organization.area.root
      @current_city = user.organization.area
      @current_district = []
      @cites = @current_province.children
      @districts = []
    when :province
      @current_province = user.organization.area
      @current_city = []
      @current_district = []
      @cites = []
      @districts = []
    end

    @organization_name = user.organization.name
    @organization_phone = user.organization.phone
    @organization_addr = user.organization.addr
    @user_name = user.name

    rs_current_province = { text: @current_province.name, id: @current_province.id }
    rs_current_city = { text: @current_city.name, id: @current_city.id }
    rs_current_district = { text: @current_district.name, id: @current_district.id }
    rs_provinces = @provinces.map { |province| { text: province.name, id: province.id } }
    rs_cities = @cites.map { |city| { text: city.name, id: city.id } }
    rs_districts = @districts.map { |district| { text: district.name, id: district.id } }

    respond_to do |format|
      format.json { render json: { current_province: rs_current_province,
                                   current_district: rs_current_district,
                                   current_city: rs_current_city,
                                   cities: rs_cities,
                                   districts: rs_districts,
                                   provinces: rs_provinces,
                                   organization_name: @organization_name,
                                   organization_addr: @organization_addr,
                                   organization_phone: @organization_phone,
                                   user_name: @user_name,
                                   user_id: user.id } }
    end
  end

  def matter_demands
    department = Department.find(params[:department_id])
    if department.matter
      matters = department.matter.split(',').map { |matter| { text: matter, id: matter } }
    else
      matters = []
    end

    respond_to do |format|
      format.json { render json: { matters: matters } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_main_case
      @main_case = MainCase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def main_case_params
      params.require(:main_case).permit(:serial_no,
                                        :case_no,
                                        :user_id,
                                        :accept_date,
                                        :case_stage,
                                        :case_close_date,
                                        :case_type,
                                        :province_id,
                                        :city_id,
                                        :district_id,
                                        :organization_name,
                                        :user_name,
                                        :organization_phone,
                                        :organization_addr,
                                        :department_id,
                                        :anyou,
                                        :case_property,
                                        :commission_date,
                                        { matter: [] },
                                        :matter_demand,
                                        :base_info,
                                        transfer_docs_attributes: [:name,
                                                                   :doc_type,
                                                                   :num,
                                                                   :unit,
                                                                   :traits,
                                                                   :status,
                                                                   :receive_date,
                                                                   :barcode,
                                                                   :attachment],
                                        appraised_unit_attributes: [:unit_type,
                                                                    :name,
                                                                    :addr,
                                                                    :gender,
                                                                    :birthday,
                                                                    :id_type,
                                                                    :id_num])
    end

    def set_provinces
      @provinces = Area.roots
    end

    def set_court_users
      @users = User.where(user_type: :court_user).map { |user| [ user.name, user.id ] }
    end

    def set_anyou_and_case_property
      @anyou = ANYOU.map { |anyou| [ anyou, anyou ] }
      @case_property = CASE_PROPERTY.map{ |case_property| [case_property, case_property] }
    end

    def set_department_matters
      if @main_case.matter.blank?
        @department_matters = []
        @selected_matters = []
      else
        @department_matters = JSON.parse(@main_case.matter).map { |matter| [matter, matter] }
        @selected_matters = if @department_matters.nil?
                              []
                            else
                              @department_matters.map(&:first)
                            end
      end
    end
end
