class V1::SchedulesController < ApplicationController
  before_action :set_service_contract, only: [:show, :create, :update, :rank_dates]
  before_action :set_dates, only: [:show, :create, :update]

  # GET /schedules
  def show
    result = Schedule::GetSchedulesService.new(@service_contract, @start_date, @end_date).perform
    if result.success?
      @schedules = result.schedules_array_hash
      render json: @schedules
    else
      render json: {message: 'Error al generar json'}
    end
  end

  # POST /schedules
  def create
    result = Schedule::CreateSchedulesService.new(@service_contract, @start_date, @end_date).perform
    if result.success?
      render json: result.schedules_array_hash, status: :created
    else
      render json: {message: 'Error al crear el calendario'}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /schedules/1
  def update
    result = Schedule::UpdateSchedulesService.new(@service_contract, @start_date, @end_date, params[:schedules]).perform
    if result.success?
      render json: result.schedules_array_hash
    else
      render json: {message: 'Error al actualizar el calendario'}, status: :unprocessable_entity
    end
  end

  def rank_dates
    result = Schedule::RankDatesAvailableService.new(@service_contract).perform
    if result.success?
      render json: result.rank_dates
    else
      render json: {message: 'Error, no se pudo obtener el rango de fechas disponible'}, status: :unprocessable_entity
    end
  end

  private
    def set_dates
      @start_date = Date.parse(params[:start_date])
      @end_date = Date.parse(params[:end_date])
    end

    def set_service_contract
      @service_contract = ServiceContract.find(params[:service_contract_id])
    end

    # Only allow a list of trusted parameters through.
    def schedule_params
      params.require(:schedule).permit(:checked, :is_confirmed, :employee_id, :contract_day_time_id)
    end
end
