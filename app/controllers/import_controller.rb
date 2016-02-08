class ImportController < ApplicationController
  def from_url
    if params.key? :wait_handle
      value = CertManager::Configuration.redis_client.get params[:wait_handle]
      resp = if value
               {
                 status: :done,
                 chain: Marshal.load(value) # TODO: Security review this
               }
             else
               {
                 status: :unfinished,
                 wait_handle: params[:wait_handle]
               }
             end
    else
      raise 'Must specify hostname' if params[:host].empty?
      job = FetchCertificateJob.perform_later(host: params[:host], port: 443)
      resp = {
        status: :unfinished,
        wait_handle: job.job_id
      }
    end
    respond_to do |format|
      format.json {
        render json: resp
      }
    end
  end

  def do_import
    key = params[:certificate][:key]
    public_keys = CertificateTools.extract_certificates(key)
    private_keys = CertificateTools.extract_private_keys(key)

    public_keys.uniq!
    ActiveRecord::Base.transaction do
      public_keys = public_keys.map { |raw|
        key = PublicKey.import raw
        key.save!
        key
      }
      private_keys = private_keys.map { |raw|
        key = PrivateKey.import raw
        key.save!
        key
      }
      @certs = []
      public_keys.each do |pub|
        certificate = Certificate.find_for_key_pair pub, nil
        certificate.touch_by current_user
        certificate.save!
        @certs << certificate
      end
      private_keys.each do |priv|
        certificate = Certificate.find_for_key_pair nil, priv
        certificate.touch_by current_user
        certificate.save!
        @certs << certificate
      end
      @certs.each do |cert|
        issuer = cert if cert.public_key.issuer_subject_id == cert.public_key.subject_id
        issuer ||= Certificate.find_by_subject_id(cert.public_key.issuer_subject_id)
        if issuer
          cert.issuer = issuer
          cert.save!
        end
      end
    end

    respond_to do |format|
      format.json do
        render json: @certs.to_json
      end
      format.html {
        if params[:return_url]
          redirect_to params[:return_url]
        else
          render 'import_done'
        end
      }
    end
  end
end
