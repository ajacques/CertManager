module AcmeHelper
  def acme_status_as_css_class(status)
    if status.invalid?
      'danger'
    elsif status.valid?
      'success'
    end
  end
end