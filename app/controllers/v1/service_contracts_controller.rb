class V1::ServiceContractsController < ApplicationController
  before_action :set_service_contract, only: [:show, :update, :destroy]

  # GET /service_contracts
  def index
    @service_contracts = ServiceContract.all.to_json(only: [:id, :company_name])

    render json: @service_contracts
  end

  # GET /service_contracts/1
  def show
    render json: @service_contract
  end

  # POST /service_contracts
  def create
    @service_contract = ServiceContract.new(service_contract_params)

    if @service_contract.save
      render json: @service_contract, status: :created, location: @service_contract
    else
      render json: @service_contract.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /service_contracts/1
  def update
    if @service_contract.update(service_contract_params)
      render json: @service_contract
    else
      render json: @service_contract.errors, status: :unprocessable_entity
    end
  end

  # DELETE /service_contracts/1
  def destroy
    @service_contract.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_contract
      @service_contract = ServiceContract.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def service_contract_params
      params.require(:service_contract).permit(:company_name)
    end
end
