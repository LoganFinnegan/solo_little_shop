Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "welcome#index"

  resources :merchants, only: [] do
    member do
      get 'dashboard', to: 'merchants#show'
    end

    resources :items, controller: 'merchant_items', except: [:destroy]
    resources :invoices, controller: 'merchant_invoices', only: [:index, :show, :update]
    resources :coupons, controller: 'merchant_coupons'
  end
#Admin
  namespace :admin do
    root to: "dashboard#index"
    resources :merchants, except: [:destroy]
    resources :invoices, only: [:index, :show, :update]
  end
end
