require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe RailsExceptionHandler::Configuration do
  describe ".storage_strategies" do
    it "should store errors in the database when storage_strategies contains :active_record" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:active_record] }
      get('/incorrect_route')
      ErrorMessage.count.should == 1
    end

    it "should store errors in the rails log when storage_strategies contains :rails_log" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:rails_log] }
      get('/home/model_error')
      read_test_log.should match /NoMethodError \(undefined method `foo' for nil:NilClass\)/
      read_test_log.should match /lib\/active_support\/whiny_nil\.rb:48/
      read_test_log.should match /PARAMS:\s+{\"controller\"=>\"home\", \"action\"=>\"model_error\"}/
      read_test_log.should match /TARGET:\s+http:\/\/example\.org\/home\/model_error/
    end

    # No idea how to integration test remote_url without spawning a dedicated test server
  end

  describe ".ignore_routing_errors" do
    it "should ignore routing errors when ignore_routing_errors is set to true" do
      RailsExceptionHandler.configure { |config| config.ignore_routing_errors = true }
      get('/incorrect_route')
      ErrorMessage.count.should == 0
    end

    it "should not ignore routing errors when ignore_routing_errors is set to false" do
      RailsExceptionHandler.configure { |config| config.ignore_routing_errors = false }
      get('/incorrect_route')
      ErrorMessage.count.should == 1
    end
  end

  describe ".ignore_crawlers" do
    it "should ignore a crawler request when ignore_crawlers is set to true" do
      RailsExceptionHandler.configure { |config| config.ignore_crawlers = true }
      get "/incorrect_route", {}, {'HTTP_USER_AGENT' => 'Slurp'}
      ErrorMessage.count.should == 0
    end

    it "should not ignore a crawler when ignore_crawlers is set to false" do
      RailsExceptionHandler.configure { |config| config.ignore_crawlers = false }
      get "/incorrect_route", {}, {'HTTP_USER_AGENT' => 'Slurp'}
      ErrorMessage.count.should == 1
    end
  end

  describe ".environments" do
    it "should not log routing errors if the current rails environment is not included" do
      Rails.configuration.middleware.delete RailsExceptionHandler
      RailsExceptionHandler.configure { |config| config.environments = [:production] }
      lambda { get('/incorrect_route') }.should raise_exception
      ErrorMessage.count.should == 0
    end

    it "should not log regular errors if the current rails environment is not included" do
      Rails.configuration.middleware.delete RailsExceptionHandler
      RailsExceptionHandler.configure { |config| config.environments = [:production] }
      lambda { get('/home/model_error') }.should raise_exception
      ErrorMessage.count.should == 0
    end

    it "should log routing errors if the rails environment is included" do
      Rails.configuration.middleware.delete RailsExceptionHandler
      RailsExceptionHandler.configure { |config| config.environments = [Rails.env.to_sym] }
      get('/incorrect_route')
      ErrorMessage.count.should == 1
      last_response.body.should match(/this_is_the_application_view/)
    end

    it "should log regular errors if the rails environment is included" do
      Rails.configuration.middleware.delete RailsExceptionHandler
      RailsExceptionHandler.configure { |config| config.environments = [Rails.env.to_sym] }
      get('/home/model_error')
      ErrorMessage.count.should == 1
      last_response.body.should match(/this_is_the_home_view/)
    end
  end

  describe ".fallback_layout" do
    it "should use the supplied layout on routing errors" do
      RailsExceptionHandler.configure { |config| config.fallback_layout = 'home' }
      get('/incorrect_route')
      last_response.body.should match(/this_is_the_home_view/)
    end
  end
end
