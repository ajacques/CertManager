class InstallController < ApplicationController
  public_endpoint

  def oauth
    @provider = OAuthProvider.new flash[:values]
    if flash.key? :errors
      flash[:errors].each do |error|
        @provider.errors.add error
      end
      flash.clear
    end
  end

  def create_provider
    provider = OAuthProvider.new(provider_params)
    if provider.save
      redirect_to new_user_session_path
    else
      flash[:values] = provider_params
      flash[:errors] = provider.errors
      respond_to do |format|
        format.html {
          redirect_to action: :oauth
        }
      end
    end
  end

  private

  def provider_params
    params.require(:o_auth_provider)
        .permit(:name, :requested_scopes, :authorize_uri_base, :token_uri_base, :client_id, :client_secret)
  end
end
