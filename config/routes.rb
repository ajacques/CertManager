Rails.application.routes.draw do
  root 'certificate#index'
  get 'new' => 'certificate#new'
  get 'import' => 'certificate#import'
  post 'import' => 'certificate#do_import'
  post 'csr' => 'csr#new'
  scope 'certificate' do
    get 'new' => 'new'
    get ':id' => 'certificate#show', as: :certificate, constraints: {
      id: /[0-9]+/
    }
    get ':id/csr' => 'certificate#csr'
    post ':id/public_key' => 'certificate#upload_pub_key'
  end
end
