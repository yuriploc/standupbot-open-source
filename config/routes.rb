Rails.application.routes.draw do

  root "standups#index"

  resources :standups, only: :index
  resources :users, only: [ :index, :update ]
  resources :settings, only: [ :index, :update, :create ]

  namespace :api do
    resources :standups, only: [] do
      get :start, on: :collection
    end

    get 'start' => 'standups#start'
  end

end
