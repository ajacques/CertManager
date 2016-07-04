module AcmeHelper
  def acme_status_as_css_class(status)
    return 'danger' if status.invalid?
    'success' if status.valid?
  end
end
