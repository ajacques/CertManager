include CrlHelper

class CertificatesController < ApplicationController
  def index
    @query = params[:search]
    @certs = Certificate.eager_load(:subject, :public_key, :private_key).includes(public_key: :_subject_alternate_names).paginate(page: params[:page])
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
          "#{cert.public_key.to_pem}\n"
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
    key = params[:certificate][:key]
    public_keys = CertificateTools.extract_certificates(key)
    private_keys = CertificateTools.extract_private_keys(key)

    public_keys.uniq!
    public_keys = public_keys.map do |raw|
      key = PublicKey.import raw
      key.save!
      key
    end
    private_keys = private_keys.map do |raw|
      key = PrivateKey.import raw
      key.save!
      key
    end
    @certs = public_keys.map do |pub|
      certificate = Certificate.find_for_key_pair pub, nil
      certificate.touch_by current_user
      certificate.save!
      certificate
    end

    respond_to do |format|
      format.json {
        render json: @certs.to_json
      }
      format.html {
        if params[:return_url]
          redirect_to params[:return_url]
        else
          render 'import_done'
        end
      }
    end
  end

  private
  def certificate_params
    params.require(:certificate)
      .permit(subject_attributes: [:O, :OU, :S, :C, :CN, :L, :ST],
              private_key_attributes: [:bit_length, :type, :curve_name])
  end
end