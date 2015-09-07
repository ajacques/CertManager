require 'resque/server'

Rails.application.routes.draw do
  root 'overview#index'
  get 'ping' => 'health_check#ping'
  get 'login' => 'sessions#new', as: :new_user_session
  post 'login' => 'sessions#create', as: :user_session
  get 'logout' => 'sessions#destroy', as: :destroy_user_session
  resources :users, only: [:create, :index, :new, :show, :update], constraints: {
    id: /[0-9]+/
  } do
    member do
      post 'lock'
      post 'unlock'
      get 'activate'
      get 'recover' => 'user_recovery#prompt', as: :reset
      post 'recover' => 'user_recovery#recover'
    end
    collection do
      get 'recover' => 'user_recovery#start'
      post 'recover' => 'user_recovery#send_mail'
      get 'recover_after' => 'user_recovery#after_send'
    end
  end
  scope :install, controller: :install, as: :install do
    get 'user'
    post 'user', action: :create_user
    get 'configure'
  end
  resources :certificates, only: [:create, :index, :new, :show], constraints: {
      id: /[0-9]+/,
      another_id: /[0-9]+/
    } do
    member do
      get 'csr'
      get 'revocation_check'
      get 'sign/:another_id' => 'signing#configure'
      post 'sign/:another_id' => 'signing#sign_cert'
    end
    collection do
      get 'import'
      post 'import/from_url', action: :import_from_url
      post 'import', action: :do_import
      post 'analyze'
    end
  end
  resources :services, constraints: {
    id: /[0-9]+/
  } do
    member do
      get 'deploy'
    end
    collection do
      get 'deployment'
      scope :salt do
        get 'nodes'
      end
    end
  end
  post 'jobs/refresh_all' => 'jobs#refresh_all'

  mount Resque::Server.new, at: '/resque'
end
