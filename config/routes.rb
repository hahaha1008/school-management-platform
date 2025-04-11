Rails.application.routes.draw do
  devise_for :users
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


namespace :api do
  namespace :v1 do
    resources :users, only: [:show, :update]
    resources :courses, only: [:index, :show] do
      resources :assignments, only: [:index, :show] do
        resources :submissions, only: [:create, :show, :update]
      end
    end
    # Authentication routes
    post 'login', to: 'authentication#login'
    post 'register', to: 'authentication#register'
  end
end


# Dashboard route
get 'dashboard', to: 'home#dashboard'

# Resources
resources :users

resources :profiles, only: [:show] do
  member do
    patch :update_avatar
  end
end

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
