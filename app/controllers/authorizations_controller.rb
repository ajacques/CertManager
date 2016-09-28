class AuthorizationsController < ApplicationController
  def create
    Authorization.create_with_identifier create_params, current_user
    redirect_to users_path
  end

  private

  def create_params
    params.require(:authorization).permit(:identifier, :o_auth_provider_id)
  end
end
