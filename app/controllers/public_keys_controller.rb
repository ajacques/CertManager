class PublicKeysController < ApplicationController
  def show
    pub = PublicKey.find params[:id]
    respond_to do |format|
      format.json {
        render json: pub
      }
      format.pem {
        render body: pub.to_pem, content_type: Mime::Type.lookup_by_extension(:pem)
      }
      format.text {
        render text: pub.to_text
      }
    end
  end
end