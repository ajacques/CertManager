include CrlHelper

class CertificatesController < ApplicationController
  def index
    query = params[:query]
    @certs = Certificate.with_everything.paginate(page: params[:page])
    if query
      @certs = @certs.joins(public_key: :subject).where('("subjects"."CN" LIKE ?)', "%#{query}%")
    end
    @certs = @certs.where(issuer_id: params[:issuer]).where('certificates.issuer_id != certificates.id') if params.has_key? :issuer
    @expiring = [] #@certs.expiring_in(30.days).order('not_after asc')
    @certs = @certs.expiring_in params[:expiring_in].to_i.seconds if params.has_key? :expiring_in
  end

  def show
    @cert = Certificate.eager_load(:public_key, :private_key).includes(:services).find(params[:id])
    self.model_id = @cert.id
    respond_to do |format|
      format.pem {
        render body: @cert.public_key.to_pem, content_type: Mime::Type.lookup_by_extension(:pem)
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
    cert.csr.private_key = cert.private_key
    cert.touch_by! current_user

    redirect_to cert
  end

  def csr
    @cert = Certificate.find params[:id]
    @csr = @cert.new_csr
    render 'csr/show'
  end

  def import_from_url
    importer = CertificateImporter.new params[:host], 443
    respond_to do |format|
      format.json {
        certs = importer.get_certs
        args = params[:properties]
        args = args & (PublicKey.attribute_names + %w(to_pem subject))
        args.map! {|s| s.to_sym}
        certs.map! do |cert|
          cert.slice(*args)
        end
        render json: certs
      }
    end
  end

  def do_import
    key = params[:certificate][:key]
    public_keys = CertificateTools.extract_certificates(key)
    private_keys = CertificateTools.extract_private_keys(key)

    public_keys.uniq!
    ActiveRecord::Base.transaction do
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
        issuer = issuer || Certificate.find_by_subject_id(cert.public_key.issuer_subject_id)
        if issuer
          cert.issuer = issuer
          cert.save!
        end
      end
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
      .permit(csr_attributes: [subject_alternate_names: [], subject_attributes: [:O, :OU, :S, :C, :CN, :L, :ST]],
              private_key_attributes: [:bit_length, :type, :curve_name])
  end
end