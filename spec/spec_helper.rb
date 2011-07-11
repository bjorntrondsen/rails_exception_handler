
ENV["RAILS_ENV"] = 'test'
require File.expand_path(File.dirname(__FILE__)) + '/exception_handler_test_app/config/environment.rb'

require File.expand_path(File.dirname(__FILE__)) + '/test_macros.rb'

require "rspec/rails"
require "rack/test"


RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include TestMacros
  config.around do |example|
    ErrorMessage.delete_all
    clear_test_log
    example.call
    ErrorMessage.delete_all
    clear_test_log
  end
  config.color_enabled = true
  config.full_backtrace = true
end
