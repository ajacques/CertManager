SecureHeaders::Configuration.default do |config|
  def asset_src
    if Rails.env.production? && ENV['CERT_ASSET_CDN']
      [ENV['CERT_ASSET_CDN']]
    else
      %w('self')
    end
  end
  config.cookies = {
    httponly: true
  }
  config.x_frame_options = 'DENY'
  config.x_download_options = SecureHeaders::OPT_OUT

  config.csp = {
    default_src: %w('none'),
    script_src: asset_src,
    style_src: asset_src,
    font_src: asset_src
  }
  # Browsersync
  if Rails.env.development?
    config.csp[:script_src] << "'sha256-OH62nWXd8EjoXubrd8JxJyNkzPjBgGuoQUBbXt2EKEs='"
    config.csp[:connect_src] = %w(ws://certmgr.devvm 'self')
  end
end
