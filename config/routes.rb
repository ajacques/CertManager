require 'resque/server'

Rails.application.routes.draw do
  root 'certificate#index'
  get 'login' => 'session#new'
  post 'login' => 'session#create'
  post 'logout' => 'session#destroy'
  resources :certificate, only: [:create, :index, :new, :show], constraints: {
      id: /[0-9]+/,
      another_id: /[0-9]+/
    } do
    get 'csr', on: :member
    get 'revocation_check', on: :member
    get 'sign/:another_id' => 'signing#configure', on: :member
    post 'sign/:another_id' => 'signing#sign_cert', on: :member
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
