class MaterialCyclesController < ApplicationController
  layout 'system'
  before_action :set_material_cycle, only: [:show, :edit, :update, :destroy]

  # GET /material_cycles
  # GET /material_cycles.json
  def index
    data = admin? ? MaterialCycle.all : @current_user.organization.material_cycles
    @material_cycles = initialize_grid(data, per_page: 20, name: 'material_cycle_grid')
  end

  # GET /material_cycles/1
  # GET /material_cycles/1.json
  def show
  end

  # GET /material_cycles/new
  def new
    @material_cycle = MaterialCycle.new
  end

  # GET /material_cycles/1/edit
  def edit
  end

  # POST /material_cycles
  # POST /material_cycles.json
  def create
    @material_cycle = MaterialCycle.new(material_cycle_params)

    respond_to do |format|
      if @material_cycle.save
        format.html { redirect_to material_cycles_path, notice: '补充材料周期已经被成功创建！' }
        format.json { render :show, status: :created, location: @material_cycle }
      else
        format.html { render :new }
        format.json { render json: @material_cycle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /material_cycles/1
  # PATCH/PUT /material_cycles/1.json
  def update
    respond_to do |format|
      if @material_cycle.update(material_cycle_params)
        format.html { redirect_to material_cycles_path, notice: '补充材料周期已经被成功更新！' }
        format.json { render :show, status: :ok, location: @material_cycle }
      else
        format.html { render :edit }
        format.json { render json: @material_cycle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /material_cycles/1
  # DELETE /material_cycles/1.json
  def destroy
    @material_cycle.destroy
    respond_to do |format|
      format.html { redirect_to material_cycles_url, notice: '补充材料周期已经被成功删除了！' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_cycle
      @material_cycle = MaterialCycle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def material_cycle_params
      params.require(:material_cycle).permit(:day, :organization_id)
    end
end
