class SigningController < ApplicationController
  def configure
    @signee = Certificate.find(params[:another_id])
    @signer = Certificate.find(params[:id])
    @public_key = PublicKey.new subject: @signee.subject
    @public_key.not_before = Time.now
    @public_key.not_after = Time.now + 1.year
    @public_key.hash_algorithm = CertManager::SecurityPolicy.hash_algorithm.default
    @allow_subject_changes = @signer != @signee
    @self_signing = @signer == @signee
  end

  def sign_cert
    signer = Certificate.find(params[:id])
    if params[:id] == params[:another_id]
     signee = signer
    else
     signee = Certificate.find(params[:another_id])
    end
    signee.public_key = public_key = PublicKey.from_private_key signee.private_key
    public_key.assign_attributes certificate_params
    signer.sign(signee)
    signee.save!

    DeployCertificateJob.perform_later signee if params[:auto_deploy]
    redirect_to signee
  end

  private
  def certificate_params
    params.require(:public_key)
      .permit(
       :hash_algorithm,
       :not_before,
       :not_after,
       :is_ca,
       extended_key_usage: [],
       key_usage: [],
       subject_attributes: Subject.safe_attributes,
       extensions_attributes: [:name, :value]
      )
  end
end