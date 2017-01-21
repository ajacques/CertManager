class ImportController < ApplicationController
  def from_url
    if params.key? :wait_handle
      value = CertManager::Configuration.redis_client.get params[:wait_handle]
      resp = if value
               JSON.parse(value)
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
    set = ImportSet.from_array params[:certificate][:key]

    set.import
    set.save
    @certs = set.promote_all_to_certificates

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
