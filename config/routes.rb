Rails.application.routes.draw do
  get "auth/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "users/", to: "auth#index"

  match "signup", to: "auth#signup", via: :post
  match "signup", to: "application#method_not_allowed", via: :all

  post "login/", to: "auth#login"
  post "refresh/", to: "auth#refresh"
  # Defines the root path route ("/")
  # root "posts#index"
end
