class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]
  before_action :set_new_areas, only: [:new, :create]
  before_action :set_edit_areas, only: [:edit, :update]

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = initialize_grid(Organization.all, per_page: 20, name: 'organization_grid')
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
    # 当用户不是超级用户，切要去编辑其他机构信息时，提示用户没有权限
    redirect_to acceptable_url('main_cases', 'index') if !@current_user.admin? && @current_user.organization.id != @organization.id
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)
    @organization.area_id = _area_id(organization_params[:province_id],
                                     organization_params[:city_id],
                                     organization_params[:district_id])
    respond_to do |format|
      if @organization.save
        format.html { redirect_to organizations_url, notice: '组织已经被成功的创建！' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    @organization.area_id = _area_id(organization_params[:province_id],
                                     organization_params[:city_id],
                                     organization_params[:district_id])
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to organizations_url, notice: '组织已经被成功的更新！' }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: '组织已经被成功的删除！' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name,
                                           :code,
                                           :desc,
                                           :area_id,
                                           :addr,
                                           :phone,
                                           :wechat_id,
                                           :org_type,
                                           :province_id,
                                           :city_id,
                                           :district_id,
                                           :abbreviation,
                                           :payee,
                                           :open_account_bank,
                                           :account_number)
    end

    def set_new_areas
      @provinces = Area.roots
      @cities = @provinces.first.children
      @districts = []
    end

    def set_edit_areas
      province_id = @organization.province_id
      city_id = @organization.city_id
      @provinces = Area.roots
      @cities = province_id.nil? ? @provinces.first.children : Area.find(province_id).children
      @districts = city_id.nil? ? [] : Area.find(city_id).children
    end
end
