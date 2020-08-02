Rails.application.routes.draw do
  # get 'orders/gift', :to => 'orders#gift'
  resources :products, only: [ :index, :show ]
  resources :orders, only: [ :new, :create, :show ]

  
  root to: "products#index"
end

