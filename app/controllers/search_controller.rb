class SearchController < ApplicationController
  def suggest
    terms = Subject.where('subjects."CN" LIKE ?', "#{params[:query]}%")
    terms = terms.map do |subject|
      subject.to_s
    end
    respond_to do |format|
     format.json {
       render json: [params[:query], terms]
     }
    end
  end
end