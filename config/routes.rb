Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
# Root path
root 'home#index'
  
# Authentication routes
get 'signup', to: 'users#new'
get 'login', to: 'sessions#new'
post 'login', to: 'sessions#create'
delete 'logout', to: 'sessions#destroy'
get 'logout', to: 'sessions#destroy'

# Dashboard route
get 'dashboard', to: 'home#dashboard'

# Resources
resources :users

# Nested resources
resources :courses do
  resources :enrollments, only: [:index, :create, :update, :destroy]
  resources :assignments do
    resources :submissions, except: [:index] do
      member do
        patch 'grade'
      end
    end
  end
end
end
