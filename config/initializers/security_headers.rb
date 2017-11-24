# rubocop:disable PercentStringArray
# Disabled because it's required for the CSP header
SecureHeaders::Configuration.default do |config|
  def asset_src
    if Rails.env.production? && ENV['CERT_ASSET_CDN']
      [ENV['CERT_ASSET_CDN']]
    else
      %w['self']
    end
  end
  config.cookies = {
    httponly: true,
    samesite: {
      lax: true
    }
  }
  config.x_frame_options = 'DENY'
  config.referrer_policy = 'no-referrer'

  config.csp = {
    default_src: %w['none'],
    script_src: asset_src,
    style_src: asset_src,
    font_src: asset_src,
    connect_src: %w['self']
  }

  # Browsersync
  if Rails.env.development?
    config.csp[:script_src] << "'sha256-OH62nWXd8EjoXubrd8JxJyNkzPjBgGuoQUBbXt2EKEs='"
    config.csp[:connect_src] = %w[ws://certmgr.localhost 'self']
  end
end

# Login page is kept minimal for reduced exposure
SecureHeaders::Configuration.override(:login_page) do |override|
  override.csp[:script_src] = []
end
