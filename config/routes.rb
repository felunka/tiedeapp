Rails.application.routes.draw do
  # For details on# the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'sessions#landing'

  get '/impressum', to: 'imprint#show'

  get 'family-tree', to: 'family_tree#show'
  get 'family-tree/data', to: 'family_tree#data'
  post 'family-tree/import', to: 'family_tree#import'

  resources :events do
    member do
      get :send_invites
      get :generate_invite_pdf
    end
  end
  resources :members do
    resources :payments, only: [:index, :new, :create]
    collection do
      get :autocomplete
    end
  end
  resources :payments, only: [:index, :destroy]
  resources :member_events, only: [:index]
  resources :users, only: [:new, :create]
  resources :registrations do
    member do
      get :success
      get :invitation
    end
  end
  resources :manage_registrations, only: [:edit, :update]
  resource :session, only: [:new, :create, :destroy] do
    get :landing
  end
end
