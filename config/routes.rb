Rails.application.routes.draw do
  root 'overview#index'
  get 'ping' => 'health_check#ping'
  get 'login' => 'sessions#new', as: :new_user_session
  scope :login do
    scope 'sso/:provider', controller: :o_auth, as: :oauth do
      root action: :begin, as: :login
      get :receive
      get :authenticate
    end
  end
  get 'logout' => 'sessions#destroy', as: :destroy_user_session
  resources :users, only: %i[index show update], constraints: {
    id: /[0-9]+/
  } do
    collection do
      resources :authorizations, only: %i[create destroy]
    end
  end
  scope :search, controller: :search, as: :search do
    get :results
    get :manifest
    get :suggestions
  end
  scope :install, controller: :install, as: :install do
    get 'oauth'
    post 'oauth', action: :create_provider
    get 'configure'
  end
  resources :certificates, only: %i[create index new show], constraints: {
    id: /[0-9]+/,
    another_id: /[0-9]+/
  } do
    member do
      get 'csr'
      get 'revocation_check'
      get 'chain'
      scope :sign, controller: :signing do
        scope :lets_encrypt, controller: :lets_encrypt do
          root action: :index, as: :lets_encrypt
          post :register
          get :prove_ownership
          post :start_import
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
  resources :acme_sign_attempts, only: %I[show destroy]
  resources :public_keys, only: %I[show]
  resources :services, constraints: {
    id: /[0-9]+/
  } do
    member do
      get 'deploy'
    end
    collection do
      get 'deployment'
    end
  end
  scope :private_keys, controller: :private_keys do
    post :analyze, as: :analyze_private_key
  end
  resource :settings, only: %i[show update] do
    member do
      post 'validate/mail_server', action: 'validate_mail_server'
    end
  end
  resources :agents, as: :agent, only: %I[new update] do
    collection do
      post :generate_token
    end
  end
  scope :agents, controller: :agents_api, as: :agent do
    get 'register/:token', action: :register, as: :register, constraints: {
      token: /([a-zA-Z0-9_\-]+\.?){3}/
    }
    post :bootstrap
    get :sync
    post :report
    get 'service/:id', action: :cert_chain, as: :service
  end
  scope :jobs, controller: :jobs, as: :jobs do
    get :refresh_all
    post :refresh_cert_bundle
  end
  get 'acme-challenge-responder/:token' => 'lets_encrypt#validate_token'

  # mount Resque::Server.new, at: '/resque'
end
