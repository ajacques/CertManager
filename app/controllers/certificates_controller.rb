include CrlHelper

class CertificatesController < ApplicationController
  def index
    @query = params[:search]
    @certs = Certificate.eager_load(:subject, :public_key, :private_key).includes(public_key: :subject_alternate_names).paginate(page: params[:page])
    if @query
      @certs = @certs.joins(:public_key).where('subjects.CN LIKE ? OR (SELECT 1 FROM subject_alternate_names san WHERE san.certificate_id = certificates.id AND san.name LIKE ?)', "%#{@query}%", "%#{@query}%")
    end
    @certs = @certs.where(issuer_id: params[:issuer]).where('certificates.issuer_id != certificates.id') if params.has_key? :issuer
    @expiring = [] #@certs.expiring_in(30.days).order('not_after asc')
    @certs = @certs.expiring_in params[:expiring_in].to_i.seconds if params.has_key? :expiring_in
  end

  def show
    @cert = Certificate.eager_load(:subject, :public_key, :private_key).includes(:services).find(params[:id])
    if params.has_key? :chain
      chain = @cert.chain
      chain.delete_at(0) if params.has_key? :exclude_root
    else
      chain = [@cert]
    end
    respond_to do |format|
      format.pem {
        render body: chain.map {|cert|
          cert.public_key.to_pem
        }.join(), content_type: Mime::Type.lookup_by_extension(:pem)
      }
      format.der {
        render body: @cert.public_key.to_der, content_type: Mime::Type.lookup_by_extension(:der)
      }
      format.html {
        if @cert.public_key
          render 'show'
        elsif @cert.stub?
          render 'show_stub'
        else
          @sign_candidates = Certificate.owned.signed.can_sign
          render 'show_csr'
        end
      }
      format.yaml {
        render plain: @cert.to_h.stringify_keys.to_yaml
      }
      format.json {
        render json: @cert
      }
      format.text {
        render text: @cert.public_key.to_text
      }
    end
  end

  def create
    cert = Certificate.new certificate_params
    cert.updated_by = current_user
    cert.created_by = current_user
    cert.save!

    redirect_to cert
  end

  def csr
    @cert = Certificate.find(params[:id])
    @csr = @cert.new_csr
    render 'csr/show'
  end

  def do_import
    certs = CertificateTools.extract_certificates(params[:key])
    keys = CertificateTools.extract_private_keys(params[:key])

    certs.uniq!
    # Welcome to hell
    @certs = []
    @bad_certs = []
    certs.each do |pem|
      begin
        r509 = R509::Cert.new cert: pem
        cert = Certificate.import pem
        cert.issuer_subject = r509.issuer
        cert.updated_by = cert.created_by = current_user
        logger.info "Certificate: #{cert.inspect} for #{r509.subject}"
        cert.save! if cert.id.nil?
        @certs << cert
      rescue => e
        logger.error "Failed to import #{cert}: #{e}"
        @bad_certs << cert
      end
    end
    keys.each { |key|
      pkey = R509::PrivateKey.new key: key
      cert = @certs.find {|c|
          c.public_key.fingerprint == Digest::SHA1.hexdigest(pkey.key.params['n'].to_s) if c.public_key
        }
      if cert.present?
        cert.private_key_data = pkey.to_pem
      end
    }
    ActiveRecord::Base.transaction do
      @certs.each { |cert|
        if cert.issuer.nil?
          issuer = Certificate.with_subject(cert.issuer_subject).first
          if issuer.present?
            cert.issuer = issuer
          else
            stub = Certificate.new_stub(cert.issuer_subject)
            stub.updated_by = stub.created_by = current_user
            cert.issuer = stub
          end
        end
        cert.save!
      }
    end
    if params[:return_url]
      redirect_to params[:return_url]
    else
      render 'import_done'
    end
  end

  private
  def certificate_params
    params.require(:certificate)
      .permit(subject_attributes: [:O, :OU, :S, :C, :CN, :L, :ST],
              private_key_attributes: [:bit_length, :type, :curve_name])
  end
end