require 'net/http'

class DeployCertificateJob < ActiveJob::Base
  queue_as :deployment

  def perform(cert)
    pub = cert.full_chain(true)
    @user = 'saltdev'
    @pass = 'saltdev'
    puts copy_file(pub)
  end

  private
  def copy_file(body)
    delete_file('/tmp/certificate')
    append_file('/tmp/certificate', body)
  end
  def delete_file(file)
    execute({
      fun: 'file.remove',
      arg: file
    })
  end
  def append_file(file, body)
    execute({
      fun: 'file.append',
      arg: [file, body]
    })
  end
  def execute(args)
    uri = URI("http://salt:8000/run")
    body = {
      username: @user,
      password: @pass,
      eauth: 'auto',
      client: 'local',
      tgt: '*',
    }
    body.merge!(args)
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req['Accept'] = 'application/x-yaml'
      req.set_form_data(body)
      YAML.load(http.request(req).body)
    end
  end
end