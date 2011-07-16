
TEST_APP = 'testapp_30'
ENV["RAILS_ENV"] = 'test'
require File.expand_path(File.dirname(__FILE__)) + "/#{TEST_APP}/config/environment.rb"

require File.expand_path(File.dirname(__FILE__)) + '/test_macros.rb'

require "rspec/rails"
require "rack/test"

ActiveRecord::Base.logger = nil
ActionController::Base.logger = nil

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include TestMacros
  config.around do |example|
    ErrorMessage.delete_all
    clear_test_log
    reset_configuration
    example.call
  end
  config.color_enabled = true
  config.full_backtrace = true
end
