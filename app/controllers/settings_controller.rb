class SettingsController < ApplicationController
  def update
    set = SettingSet.new
    set.assign_attributes params.require(:setting_set).permit(:acme_client, :smtp_address, :smtp_port)
    ActionMailer::Base.smtp_settings['address'] = set.smtp_address if set.smtp_address_changed?
    ActionMailer::Base.smtp_settings['port'] = set.smtp_port if set.smtp_port_changed?
    set.save!

    redirect_to settings_path
  end
end
