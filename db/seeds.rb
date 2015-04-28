# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create!({email: 'user@example.com', password: 'testtest', can_login: true, first_name: 'John-Paul', last_name: 'Jones'})

def new_csr!(opts={})
  subject = Subject.new opts.slice(*Subject.safe_attributes)
  private = PrivateKey.new opts.slice(:key_type, :bit_length, :curve_name)
  cert_props = opts.slice(:issuer).merge({ subject: subject, private_key: private, created_by: opts[:user], updated_by: opts[:user] })
  cert = Certificate.new(cert_props)
  cert.save!
  cert
end

def new_key_pair!(opts={})
  subject = Subject.new opts.slice(*Subject.safe_attributes)
  private = PrivateKey.new opts.slice(:key_type, :bit_length, :curve_name)
  public = PublicKey.from_private_key(private)
  public.subject = subject
  public.hash_algorithm = 'sha256'
  public.not_before = Time.now
  public.not_after = Time.now + 1.year
  public.assign_attributes opts.slice(:is_ca, :key_usage, :extended_key_usage)
  cert_props = opts.slice(:issuer).merge({ subject: subject, private_key: private, public_key: public, created_by: opts[:user], updated_by: opts[:user] })
  cert = Certificate.new(cert_props)
  signer = opts[:issuer] || cert
  signer.sign(cert)
  cert.issuer = signer
  cert.save!
  cert
end

ca = new_key_pair!({
  CN: 'Fintech Internal CA',
   O: 'Fintech, Inc.',
   OU: 'InfoSec',
   L: 'United States',
   key_type: 'rsa',
   bit_length: 2048,
   user: user,
   is_ca: true,
   key_usage: [:keyCertSign, :cRLSign],
   extended_key_usage: [:OCSPSigning]
})

new_key_pair! CN: 'fintech.com', O: 'Fintech, Inc.', OU: 'Web Services', key_type: 'rsa', bit_length: 2048, user: user, issuer: ca
#new_key_pair! CN: 'ec.fintech.com', O: 'Fintech, Inc.', OU: 'Web Services', key_type: 'ec', curve_name: 'secp384r1', user: user, issuer: ca

new_csr! CN: 'new.fintech.com', O: 'Fintech, Inc.', OU: 'Web Services', key_type: 'rsa', bit_length: 2048, user: user, issuer: ca