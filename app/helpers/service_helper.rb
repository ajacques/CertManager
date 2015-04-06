module ServiceHelper
  def options_for_certificate_list(certs)
    options_for_select(certs.map {|cert|
      [cert.subject, cert.id, {data: {ca: cert.can_sign?}}]
    })
  end
end