# rubocop:disable PercentStringArray, Metrics/BlockLength
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

  config.csp[:report_uri] = [ENV['CSP_REPORT_URI']] if ENV.key? 'CSP_REPORT_URI'

  if ENV.key? 'SENTRY_DSN'
    uri = URI(ENV['SENTRY_DSN'])
    uri.user = nil
    uri.password = nil
    uri.path = ''
    config.csp[:connect_src] << uri.to_s
  end

  # Browsersync
  if Rails.env.development?
    config.csp[:script_src] << "'sha256-OH62nWXd8EjoXubrd8JxJyNkzPjBgGuoQUBbXt2EKEs='"
    config.csp[:script_src] << "'unsafe-eval'" # Eval required for Webpacker
    config.csp[:style_src] << "'sha256-0CiLBo2RTQ3MsLt6a9DB06zBsgxOhwdsotcr/cQgmu4='" # Error page CSS
    config.csp[:connect_src] << 'ws://certmgr.localhost'
  end
end
# rubocop:enable PercentStringArray, Metrics/BlockLength

# Login page is kept minimal for reduced exposure
SecureHeaders::Configuration.override(:login_page) do |override|
  override.csp[:script_src] = []
end
