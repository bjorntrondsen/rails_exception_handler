require "rack/test"
require "test/unit"

require File.dirname(File.expand_path(__FILE__)) + '/exception_handler_test_app/config/environment.rb'
Rails.env = 'test'

class ExceptionHandlerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rails.application.app
  end

  def test_catches_routing_errors
    get "/home"
    assert_equal("An error has occurred", last_response.body)
  end

end
