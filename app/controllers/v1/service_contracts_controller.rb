class V1::ServiceContractsController < ApplicationController
  # GET /service_contracts
  def index
    @service_contracts = ServiceContract.all.to_json(only: [:id, :company_name])

    render json: @service_contracts
  end
end
