
ENV["RAILS_ENV"] = 'test'

require 'rails'
if(Rails::VERSION::MINOR > 1)
  puts "Testing against a rails 3.2 dummy app"
  TEST_APP = 'dummy_32'
else
  puts "Testing against a rails 3.0 dummy app"
  TEST_APP = 'dummy_30'
end
require File.expand_path(File.dirname(__FILE__)) + "/#{TEST_APP}/config/environment.rb"

require File.expand_path(File.dirname(__FILE__)) + '/test_macros.rb'

require "rspec/rails"
require "rack/test"

ActiveRecord::Base.logger = nil
ActionController::Base.logger = nil

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include TestMacros
  config.color_enabled = true
  config.full_backtrace = true
  config.before(:each) do
    ErrorMessage.delete_all
    clear_test_log
    reset_configuration
  end
end
