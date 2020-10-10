class FrequentContactsController < ApplicationController
  before_action :set_frequent_contact, only: [:show, :edit, :update, :destroy]
  before_action :set_new_areas, only: [:index]
  before_action :set_edit_areas, only: [:edit]
  skip_before_action :can, only: [:create, :user_search, :index, :organization_and_user, :edit, :destroy, :update]


  # GET /frequent_contacts
  # GET /frequent_contacts.json
  def index
    data = @current_user.organization.frequent_contacts
    @frequent_contacts = initialize_grid(data,
                                         order: 'created_at',
                                         order_direction: 'desc',
                                         per_page: 10,
                                         enable_export_to_csv: true,
                                         csv_file_name: 'frequent_contacts',
                                         csv_field_separator: ',',
                                         name: 'frequent_contacts_grid')
    export_grid_if_requested('frequent_contacts_grid' => 'frequent_contacts_grid')
  end

  # GET /frequent_contacts/1
  # GET /frequent_contacts/1.json
  def show
  end

  # GET /frequent_contacts/new
  def new
    @frequent_contact = FrequentContact.new
  end

  # GET /frequent_contacts/1/edit
  def edit
  end

  # POST /frequent_contacts
  # POST /frequent_contacts.json
  def create
    @frequent_contact = @current_user.organization.frequent_contacts.new(frequent_contact_params)

    respond_to do |format|
      if @frequent_contact.save
        flash.now[:success] = "常用联系人创建成功！"
        format.js
      else
        flash.now[:danger] = "常用联系人创建失败：#{@frequent_contact.errors.full_messages.join('; ')}"
        format.js
      end
    end
  end

  # PATCH/PUT /frequent_contacts/1
  # PATCH/PUT /frequent_contacts/1.json
  def update
    respond_to do |format|
      if @frequent_contact.update(frequent_contact_params)
        format.html { redirect_to frequent_contacts_url, notice: '常用联系人更新成功！' }
        format.json { render :show, status: :ok, location: @frequent_contact }
      else
        format.html { render :edit }
        format.json { render json: @frequent_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /frequent_contacts/1
  # DELETE /frequent_contacts/1.json
  def destroy
    @frequent_contact.destroy
    respond_to do |format|
      format.html { redirect_to frequent_contacts_url, notice: '常用联系人删除成功！' }
      format.json { head :no_content }
    end
  end

  def user_search
    user_name = params[:user_name]
    res = @current_user.organization.frequent_contacts.where('name like ?', "#{user_name}").map do |user|
      user.name = "#{ user.try(:name) } 所属机构：#{ user.client_name }"
      user
    end

    render json: { users: res }
  end

  def organization_and_user
    user = FrequentContact.find(params[:user_id])

    @current_province = Area.find_by(id: user.province_id)
    @current_city = Area.find_by(id: user.city_id)
    @current_district = Area.find_by(id: user.district_id)
    @provinces = Area.roots
    @cites = @current_province.children
    @districts = @current_city.children

    @organization_name = user.client_name
    @wtr_phone = user.phone
    @organization_addr = user.client_addr
    @user_name = user.name

    rs_current_province = { name: @current_province.name, id: @current_province.id }
    rs_current_city = { name: @current_city.name, id: @current_city.id }
    rs_current_district = { name: @current_district.name, id: @current_district.id }
    rs_provinces = @provinces.map { |province| { name: province.name, id: province.id } }
    rs_cities = @cites.map { |city| { name: city.name, id: city.id } }
    rs_districts = @districts.map { |district| { name: district.name, id: district.id } }

    respond_to do |format|
      format.json { render json: { current_province: rs_current_province,
                                   current_district: rs_current_district,
                                   current_city: rs_current_city,
                                   cities: rs_cities,
                                   districts: rs_districts,
                                   provinces: rs_provinces,
                                   organization_name: @organization_name,
                                   organization_addr: @organization_addr,
                                   wtr_phone: @wtr_phone,
                                   user_name: @user_name,
                                   user_id: user.id } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_frequent_contact
      @frequent_contact = FrequentContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def frequent_contact_params
      params.require(:frequent_contact).permit(:name,
                                               :province_id,
                                               :city_id,
                                               :district_id,
                                               :organization_id,
                                               :client_name,
                                               :phone,
                                               :client_addr)
    end

    def set_new_areas
      @provinces = Area.roots.map { |province| [province.name, province.id] }
      @cities =  Area.find(@provinces.first[1]).children.map { |item| [item.name, item.id] }
      @districts = Area.find(@cities.first[1]).children.map { |item| [item.name, item.id] }
    end

    def set_edit_areas
      province_id = @frequent_contact.province_id
      city_id = @frequent_contact.city_id
      @provinces = Area.roots
      @cities = province_id.nil? ? @provinces.first.children : Area.find(province_id).children
      @districts = city_id.nil? ? [] : Area.find(city_id).children
    end
end
