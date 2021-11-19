Rails.application.routes.draw do
  # For details on# the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'sessions#landing'

  resources :events
  resources :members
  resources :member_events, only: [:index]
  resources :users, only: [:new, :create]
  resources :registrations do
    member do
      get :success
    end
  end
  resource :session, only: [:new, :create, :destroy] do
    get :landing
  end
end
