# Load rails environment
ENV["RAILS_ENV"] = 'test'
require_relative 'exception_handler_test_app/config/environment.rb'

require "rspec/rails"
require "rack/test"

describe "rails-exception_handler" do
  include Rack::Test::Methods

  def app
    Rails.application.app
  end

  after(:each) do
    ErrorMessage.destroy_all
  end

  it "should catch controller errors" do
    get "/home/action_with_error"
    ErrorMessage.count.should == 1
    last_response.body.should match(/An error has occurred/)
    ErrorMessage.destroy_all
  end

  it "should store the correct information in the database" do
    get "/home/action_with_error"
    ErrorMessage.count.should == 1
    msg = ErrorMessage.first
    msg.app_name.should == 'ExceptionHandlerTestApp'
    ErrorMessage.destroy_all
  end

end
