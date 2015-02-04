require 'resque/server'

Rails.application.routes.draw do
  root 'certificate#index'
  get 'certificate/import' => 'certificate#import'
  post 'certificate/import' => 'certificate#do_import'
  resources :certificate, only: [:create, :index, :new, :show], constraints: {
      id: /[0-9]+/,
      another_id: /[0-9]+/
    } do
    get 'csr', on: :member
    get 'revocation_check', on: :member
    get 'sign/:another_id' => 'signing#configure', on: :member
    post 'sign/:another_id' => 'signing#sign_cert', on: :member
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

  mount Resque::Server.new, at: '/resque'
end
