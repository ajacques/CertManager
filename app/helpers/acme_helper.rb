module AcmeHelper
  def acme_status_as_css_class(status)
    return 'danger' if status.invalid?
    'success' if status.valid?
  end

  def acme_sign_attempt_path(attempt)
    acme_import_status_certificate_path(id: attempt.certificate_id, attempt_id: attempt.id)
  end
end
