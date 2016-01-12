Rails.application.routes.draw do

  root "standups#index"

  resources :standups, only: :index
  resources :users, only: [ :index, :update ]
  resources :settings, only: [ :index, :update, :create ]

  namespace :api do
    get 'start' => 'standups#start'
  end

end
