Rails.application.routes.draw do
  # For details on# the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'sessions#landing'

  get '/impressum', to: 'imprint#show'
  get '/satzung', to: 'statutes#show'

  get 'family-tree', to: 'family_tree#show'
  get 'family-tree/data', to: 'family_tree#data'
  post 'family-tree/import', to: 'family_tree#import'

  resources :albums do
    resources :album_pictures, only: %i[create update destroy]
  end

  resources :article_collections do
    resources :articles, except: [:index]
  end

  resources :events do
    member do
      post :send_email
      get :generate_invite_pdf
    end
  end
  resources :members do
    resources :payments, only: %i[index new create]
    collection do
      get :autocomplete
    end
  end
  resources :payments, only: %i[index destroy]
  resources :member_events, only: [:index]
  resources :users, only: %i[new create]
  resources :registrations do
    member do
      get :success
      get :invitation
    end
  end
  resources :manage_registrations, only: %i[edit update]
  resource :session, only: %i[new create destroy] do
    get :landing
  end
end
