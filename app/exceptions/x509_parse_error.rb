class X509ParseError < RuntimeError
  attr_reader :cert, :message

  def initialize(cert:, message:)
    super
    @cert = cert
    @message = message
  end
end
