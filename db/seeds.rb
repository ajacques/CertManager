# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create!({email: 'user@example.com', password: 'testtest', can_login: true, first_name: 'John-Paul', last_name: 'Jones'})

subject = Subject.new CN: 'Fintech Internal CA', O: 'Fintech, Inc.', OU: 'InfoSec'
key = PrivateKey.new key_type: 'rsa', bit_length: 2048

Certificate.create! subject: subject, private_key: key, created_by: user, updated_by: user