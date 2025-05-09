
ENV["RAILS_ENV"] = 'test'

require 'rails'
if(Rails::VERSION::MAJOR == 8 && Rails::VERSION::MINOR == 0)
  puts "Testing against a rails 8.0 dummy app"
  TEST_APP = 'dummy_80'
elsif(Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR >= 1)
  puts "Testing against a rails 7.1 dummy app"
  TEST_APP = 'dummy_71'
elsif(Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR == 0)
  puts "Testing against a rails 7.0 dummy app"
  TEST_APP = 'dummy_70'
elsif(Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR == 1)
  puts "Testing against a rails 6.0 dummy app"
  TEST_APP = 'dummy_60'
elsif(Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR == 2)
  puts "Testing against a rails 5.1 dummy app"
  TEST_APP = 'dummy_51'
elsif(Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 2)
  puts "Testing against a rails 4.2 dummy app"
  TEST_APP = 'dummy_42'
elsif(Rails::VERSION::MAJOR == 4)
  puts "Testing against a rails 4.0 dummy app"
  TEST_APP = 'dummy_40'
elsif(Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 1)
  puts "Testing against a rails 3.2 dummy app"
  TEST_APP = 'dummy_32'
elsif(Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0)
  puts "Testing against a rails 3.0 dummy app"
  TEST_APP = 'dummy_30'
else
  raise "Dont know which version of Rails to test against for #{Rails.version}"
end
require File.expand_path(File.dirname(__FILE__)) + "/#{TEST_APP}/config/environment.rb"

require File.expand_path(File.dirname(__FILE__)) + '/test_macros.rb'

require "rspec/rails"
require "rack/test"

ActiveRecord::Base.logger = nil
ActionController::Base.logger = nil

RSpec.configure do |config|
  config.include RSpec::Rails::ViewRendering
  config.include Rack::Test::Methods
  config.include TestMacros
  config.color = true
  config.full_backtrace = true
  config.before(:each) do
    reset_configuration
    clear_test_log
    ActionMailer::Base.deliveries = []
    RailsExceptionHandler::ActiveRecord::ErrorMessage.delete_all
    RailsExceptionHandler::Mongoid::ErrorMessage.delete_all if(defined?(Mongoid) && RailsExceptionHandler.configuration.activate? && RailsExceptionHandler.configuration.mongoid?)
  end
  config.before(:each) do
    delete_static_error_pages
  end
  config.expect_with(:rspec) { |c| c.syntax = [:expect, :should] }
  config.mock_with(:rspec) { |c| c.syntax = [:expect, :should] }
end
