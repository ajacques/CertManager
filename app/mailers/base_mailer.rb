class BaseMailer < ActionMailer::Base
  attr_reader :mail_settings
  before_action :load_settings
  after_action :set_from, :set_delivery_options

  protected

  def load_settings
    @mail_settings = Settings::EmailServer.new
  end

  def set_from
    mail.from = "#{t 'brand'} <#{mail_settings.from_address}>"
  end

  def set_delivery_options
    mail.delivery_method.settings.merge!(mail_settings.action_mailer_settings)
  end

  def default_url_options(_opts = nil)
    {
      host: 'certmgr.devvm',
      protocol: 'http'
    }
  end
end
