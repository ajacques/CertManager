# Be sure to restart your server when you modify this file.

Rails.application.config.send(:session_store, CertManager::Configuration.session[:type], **CertManager::Configuration.session[:options].symbolize_keys)
