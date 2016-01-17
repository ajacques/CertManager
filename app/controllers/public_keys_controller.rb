class PublicKeysController < ApplicationController
  def show
    pub = PublicKey.find params[:id]
    respond_to do |format|
      format.json {
        render json: pub
      }
      format_render_blocks(format, pub, :pem, :text)
    end
  end

  private
  def format_render_blocks(format, obj, *formats)
    formats.each do |f|
      proc = Proc.new {
        render body: obj.send("to_#{f}"), content_type: Mime::Type.lookup_by_extension(f)
      }
      format.send(f, &proc)
    end
  end
end