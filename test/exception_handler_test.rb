require "test/unit"
require "rack/test"

# Load rails environment
ENV["RAILS_ENV"] = 'test'
require_relative 'exception_handler_test_app/config/environment.rb'

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("exception_handler_test_app/db/migrate/", __FILE__)


class ExceptionHandlerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rails.application.app
  end

  def test_catches_controller_errors
    get "/home/action_with_error"
    assert(last_response.body.match(/An error has occurred/), 'incorrect response')
    assert(ErrorMessage.count == 1, "message count should be 1, but was #{ErrorMessage.count}")
    ErrorMessage.destroy_all
  end

  def test_stores_correct_information
    get "/home/action_with_error"
    assert(ErrorMessage.count == 1, "message count should be 1, but was #{ErrorMessage.count}")
    msg = ErrorMessage.first
    assert(msg.app_name == 'ExceptionHandlerTestApp', 'app_name field is wrong')
    ErrorMessage.destroy_all
  end

end
