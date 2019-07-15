class IdentificationCyclesController < ApplicationController
  before_action :set_identification_cycle, only: [:show, :edit, :update, :destroy]

  # GET /identification_cycles
  # GET /identification_cycles.json
  def index
    data = @current_user.organization.identification_cycles
    @identification_cycles = initialize_grid(data, per_page: 20, name: 'identification_cycle_grid')
  end

  # GET /identification_cycles/1
  # GET /identification_cycles/1.json
  def show
  end

  # GET /identification_cycles/new
  def new
    @identification_cycle = IdentificationCycle.new
  end

  # GET /identification_cycles/1/edit
  def edit
  end

  # POST /identification_cycles
  # POST /identification_cycles.json
  def create
    @identification_cycle = IdentificationCycle.new(identification_cycle_params)

    respond_to do |format|
      if @identification_cycle.save
        format.html { redirect_to identification_cycles_path, notice: '鉴定周期已经被成功创建！' }
        format.json { render :show, status: :created, location: @identification_cycle }
      else
        format.html { render :new }
        format.json { render json: @identification_cycle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identification_cycles/1
  # PATCH/PUT /identification_cycles/1.json
  def update
    respond_to do |format|
      if @identification_cycle.update(identification_cycle_params)
        format.html { redirect_to identification_cycles_path, notice: '鉴定周期已经被成功更新！' }
        format.json { render :show, status: :ok, location: @identification_cycle }
      else
        format.html { render :edit }
        format.json { render json: @identification_cycle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identification_cycles/1
  # DELETE /identification_cycles/1.json
  def destroy
    @identification_cycle.destroy
    respond_to do |format|
      format.html { redirect_to identification_cycles_url, notice: '鉴定周期已经被成功删除了！' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_identification_cycle
      @identification_cycle = IdentificationCycle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def identification_cycle_params
      params.require(:identification_cycle).permit(:day, :organization_id)
    end
end
