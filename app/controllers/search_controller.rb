class SearchController < ApplicationController
  def suggestions
    certs = certificates
    resp = [
      params[:query], certs.map(&:to_s)
    ]
    respond_to do |format|
      format.json {
        render json: resp
      }
    end
  end

  def results
    certs = certificates
    certs = certs.map do |cert|
      {
        id: cert.id,
        subject: cert.subject.CN,
        type: 'certificate',
        url: certificate_path(cert)
      }
    end
    respond_to do |format|
      format.json {
        render json: certs
      }
    end
  end

  private

  def certificates
    query = params[:query].downcase
    Certificate.joins(public_key: :subject).where('(LOWER("subjects"."CN") LIKE ?)', "%#{query}%")
  end
end
