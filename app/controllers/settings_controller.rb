class SettingsController < ApplicationController
  def update
    set = SettingSet.new
    set.assign_attributes params.require(:setting_set).permit(:acme_client)
    set.save!

    redirect_to settings_path
  end
end
