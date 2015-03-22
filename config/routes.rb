require 'resque/server'

Rails.application.routes.draw do
  root 'certificates#index'
  get 'ping' => 'health_check#ping'
  get 'login' => 'sessions#new', as: :new_user_session
  post 'login' => 'sessions#create', as: :user_session
  post 'logout' => 'sessions#destroy', as: :destroy_user_session
  resource :user, only: [:show] do
    get 'two_factor' => 'sessions#two_factor'
  end
  resources :certificates, only: [:create, :index, :new, :show], constraints: {
      id: /[0-9]+/,
      another_id: /[0-9]+/
    } do
    member do
      get 'chain'
      get 'csr'
      get 'revocation_check'
      get 'sign/:another_id' => 'signing#configure'
      post 'sign/:another_id' => 'signing#sign_cert'
    end
    collection do
      get 'import'
      post 'import', action: :do_import
    end
  end
  resources :services, only: [:create, :index, :new, :show] do
    member do
      get 'deploy'
    end
    collection do
      get 'deployment'
      get 'nodes'
    end
  end
  post 'jobs/refresh_all' => 'jobs#refresh_all'

  mount Resque::Server.new, at: '/resque'
end
