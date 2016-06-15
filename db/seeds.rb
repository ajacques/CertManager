# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def configure_agents
  cert = ECPrivateKey.new curve_name: :secp384r1
  cert.save!
  settings = Settings::AgentConfig.new
  settings.private_key_id = cert.id
  settings.save!
end

configure_agents

load(Rails.root.join('db', 'seeds', "#{Rails.env.downcase}.rb"))
