Rails.application.routes.draw do
  # For details on# the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'sessions#landing'

  resources :events do
    member do
      get :send_invites
    end
  end
  resources :members do
    resources :payments
    collection do
      get :autocomplete
    end
  end
  resources :member_events, only: [:index]
  resources :users, only: [:new, :create]
  resources :registrations do
    member do
      get :success
      get :admin_edit
    end
  end
  resource :session, only: [:new, :create, :destroy] do
    get :landing
  end
end
