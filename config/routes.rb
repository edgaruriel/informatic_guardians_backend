Rails.application.routes.draw do


  namespace :v1, format: :json do
    resources :service_contracts
    resources :employees
    resource :schedules
  end

end
