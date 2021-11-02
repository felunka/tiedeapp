Rails.application.routes.draw do
  # For details on# the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'registrations#new'

  resources :registrations
  resources :events
  resources :members
  resource :session, only: [:new, :create, :destroy] do
    get :landing
  end
end
