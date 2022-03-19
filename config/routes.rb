Rails.application.routes.draw do


  namespace :v1, format: :json do
    resources :service_contracts, only: [:index]
    resource :schedules, except: [:destroy] do
      collection do
        get 'rank_dates'
      end
    end
  end

end
