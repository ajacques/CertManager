include CrlHelper

class CertificatesController < ApplicationController
  def index
    query = CertificateFilter.new params.permit(:query, :page, :issuer, :expiring_in)
    query.order_by_cn
    @certs = query.to_results
    @expiring = [] # @certs.expiring_in(30.days).order('not_after asc')
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

  def chain
    cert = Certificate.eager_load(:public_key, :private_key).find(params[:id])
    respond_to do |format|
      format.pem {
        render plain: cert.chain.map { |item|
          item.public_key.to_pem
        }.join("\n")
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
    @csr = CertificateSignRequest.find_by_certificate_id params[:id]
    @csr = CertificateSignRequest.from_cert(Certificate.find(params[:id])) unless @csr
    render 'csr/show'
  end

  def analyze
    cert = PublicKey.import request.body.read
    respond_to do |format|
      format.json {
        render json: cert.to_h
      }
      format.text {
        render plain: cert.to_text
      }
      format.yaml {
        render plain: cert.to_yaml
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
