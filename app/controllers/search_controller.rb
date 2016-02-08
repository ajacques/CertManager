class SearchController < ApplicationController
  def suggest
    query = params[:query].downcase
    certs = Certificate.joins(public_key: :subject).where('(LOWER("subjects"."CN") LIKE ?)', "%#{query}%")
    resp = [
      params[:query], certs.map(&:to_s)
    ]
    respond_to do |format|
     format.json {
       render json: resp
     }
    end
  end
end
