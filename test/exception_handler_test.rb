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

  def test_catches_rails_exceptions
    get "/home/action_with_error"
    assert_equal("An error has occurred", last_response.body)
  end

end
