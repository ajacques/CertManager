class OverviewController < ApplicationController
  def index
    @certs = Certificate.all.joins(:public_key)
    @expiring = @certs.expiring_in 30.days
    @bad_hashes = @certs.where 'public_keys.hash_algorithm NOT IN (?)', CertManager::SecurityPolicy.hash_algorithm.secure
    @by_hash = @certs.group 'public_keys.hash_algorithm'
  end
end
