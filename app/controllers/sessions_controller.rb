class SessionsController < ApplicationController
  include Authenticator
  public_endpoint

  def new
    return redirect_to root_path if current_user

    @error_message = flash[:error]
    @provider = OAuthProvider.github
    use_secure_headers_override(:login_page)

    redirect_to install_oauth_path unless @provider
  end

  def destroy
    session.destroy
    reset_session
    redirect_to new_user_session_path
  end

  def validate
    if current_user
      head :no_content
    else
      render status: 403, plain: ''
    end
  end
end
