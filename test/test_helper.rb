ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  %W(public_key private_key).each do |type|
    define_method("#{type}_raw") do |name|
      yaml = YAML.load_file("#{Rails.root}/test/data_sets/#{type.pluralize}.yml")
      yaml[name.to_s]
    end
  end
end
