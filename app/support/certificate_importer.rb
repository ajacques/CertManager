require 'openssl'
require 'socket'

class CertificateImporter
  def initialize(host, port)
    @host = host
    @port = port
  end

  def fetch_certs
    connect
    certs = grab_cert
    disconnect
    certs.map do |cert|
      PublicKey.import cert.to_s
    end
  end

  private

  def connect
    @socket = TCPSocket.new @host, @port
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_socket = OpenSSL::SSL::SSLSocket.new @socket, @ssl_context
    @ssl_socket.hostname = @host
    @ssl_socket.connect
  end

  def disconnect
    @ssl_socket.close
  end

  def grab_cert
    @ssl_socket.peer_cert_chain
  end
end
