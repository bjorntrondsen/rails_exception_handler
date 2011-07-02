
ENV["RAILS_ENV"] = 'test'
require_relative 'exception_handler_test_app/config/environment.rb'

require "rspec/rails"
require "rack/test"

module RackTestHelper
  def app # Needed by Rack::Test
    Rails.application.app
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RackTestHelper
  config.around do |example|
    ErrorMessage.delete_all
    example.call
    ErrorMessage.delete_all
  end
  config.color_enabled = true
  config.full_backtrace = true
end
