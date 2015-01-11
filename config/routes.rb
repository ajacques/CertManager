require 'resque/server'

Rails.application.routes.draw do
  root 'certificate#index'
  get 'new' => 'certificate#new'
  post 'new' => 'certificate#create'
  get 'import' => 'certificate#import'
  post 'import' => 'certificate#do_import'
  scope 'certificate' do
    get 'new' => 'new', as: :certificates
    get ':id' => 'certificate#show', as: :certificate, constraints: {
      id: /[0-9]+/
    }
    get ':id/csr' => 'certificate#csr'
    get ':id/revocation_status' => 'certificate#revocation_check'
    get ':id/sign/:another_id' => 'signing#configure'
    post ':id/sign/:another_id' => 'signing#sign_cert'
  end
  mount Resque::Server.new, at: '/resque'
end
