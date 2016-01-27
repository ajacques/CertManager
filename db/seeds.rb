# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create!(
  email: 'user@example.com',
  password: 'testtest',
  can_login: true,
  first_name: 'John-Paul',
  last_name: 'Jones',
  time_zone: 'America/Los_Angeles' # PST
)

def new_csr!(opts = {})
  subject = Subject.new opts.slice(*Subject.safe_attributes)
  private = opts[:key_type].new opts.slice(:bit_length, :curve_name)

  cert_props = opts.slice(:issuer).merge(
    private_key: private,
    created_by: opts[:user],
    updated_by: opts[:user])
  cert = Certificate.new(cert_props)
  csr = CertificateSignRequest.new subject: subject, private_key: private, certificate: cert
#  csr.assign_attributes opts.slice(:subject_alternate_names)
  csr.save!
  csr
end

def new_key_pair!(opts = {})
  subject = Subject.new opts.slice(*Subject.safe_attributes)
  private = opts[:key_type].new opts.slice(:bit_length, :curve_name)
  public = private.create_public_key
  public.subject = subject
  public.hash_algorithm = opts[:hash_algorithm] || 'sha256'
  public.not_before = Time.now
  public.not_after = Time.now + 1.year
  public.private_key = private
  public.assign_attributes opts.slice(:is_ca, :key_usage, :extended_key_usage)
  cert_props = opts.slice(:issuer).merge(private_key: private, public_key: public, created_by: opts[:user], updated_by: opts[:user])
  cert = Certificate.new cert_props
  public.certificate_id = cert.id
  signer = opts[:issuer] || cert
  signer.sign(cert)
  cert.issuer = signer
  cert.save!
  cert
end

ca = new_key_pair!(CN: 'Fintech Internal CA',
                   O: 'Fintech, Inc.',
                   OU: 'InfoSec',
                   C: 'US',
                   key_type: RSAPrivateKey,
                   bit_length: 2048,
                   user: user,
                   is_ca: true,
                   key_usage: [:keyCertSign, :cRLSign],
                   extended_key_usage: [:OCSPSigning])

leaf = new_key_pair!(CN: 'fintech.com',
                     O: 'Fintech, Inc.',
                     OU: 'Web Services',
                     key_type: RSAPrivateKey,
                     bit_length: 2048,
                     user: user,
                     issuer: ca,
                     key_usage: [:keyEncipherment],
                     extended_key_usage: [:serverAuth])
# new_key_pair! CN: 'ec.fintech.com', O: 'Fintech, Inc.', OU: 'Web Services', key_type: ECPrivateKey, curve_name: 'secp384r1', user: user, issuer: ca

new_csr!(
  CN: 'new.fintech.com',
  O: 'Fintech, Inc.',
  OU: 'Web Services',
  key_type: RSAPrivateKey,
  bit_length: 2048,
  user: user,
  issuer: ca,
  subject_alternate_names: ['alt.fintech.com']
)

Service.create! certificate: leaf, cert_path: '/tmp/fintech.com', after_rotate: 'exit 0', deploy_strategy: :salt, node_group: '*'
