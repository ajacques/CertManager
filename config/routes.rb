require 'resque/server'

Rails.application.routes.draw do
  root 'certificate#index'
  get 'login' => 'session#new', as: :new_user_session
  post 'login' => 'session#create', as: :user_session
  post 'logout' => 'session#destroy', as: :destroy_user_session
  resources :certificate, only: [:create, :index, :new, :show], constraints: {
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
  resources :service, only: [:create, :index, :new, :show] do
    member do
      get 'deploy'
    end
    collection do
      get 'deployment'
      get 'nodes'
    end
  end
  post 'jobs/refresh_all' => 'job#refresh_all'

  mount Resque::Server.new, at: '/resque'
end
