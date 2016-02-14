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
  scope :search, controller: :search, as: :search do
    get :results
    get :manifest
    get :suggest
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
      scope :sign, controller: :signing do
        scope :lets_encrypt, controller: :lets_encrypt do
          root action: :index, as: :lets_encrypt
          post :register
          get :prove_ownership
          post :formal_verification
          get :verify_done
          post :sign_csr
        end
      end
      get 'sign/:another_id' => 'signing#configure'
      post 'sign/:another_id' => 'signing#sign_cert'
    end
    collection do
      get 'import'
      scope :import, controller: :import do
        get 'from_url', action: :from_url
        post 'from_url', action: :from_url
        post '', action: :do_import
      end
      post 'analyze'
    end
  end
  resources :public_keys, only: [:show]
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
  scope :private_keys, controller: :private_keys do
    post :analyze, as: :analyze_private_key
  end
  resource :settings, only: [:show, :update]
  post 'jobs/refresh_all' => 'jobs#refresh_all'
  get 'acme-challenge-responder/:token' => 'lets_encrypt#validate_token'

  mount Resque::Server.new, at: '/resque'
end
