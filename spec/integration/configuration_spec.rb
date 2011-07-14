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

  describe '.filters' do
    describe ":all_routing_errors" do
      it "should ignore routing errors when the filters contains :all_routing_errors" do
        RailsExceptionHandler.configure { |config| config.filters = [:all_routing_errors]}
        get('/incorrect_route')
        ErrorMessage.count.should == 0
      end

      it "should not ignore routing errors when the filters doesnt contain :all_routing_errors" do
        RailsExceptionHandler.configure { |config| config.filters = []}
        get('/incorrect_route')
        ErrorMessage.count.should == 1
      end
    end

    describe ":routing_errors_without_referer" do
      it "should not store a routing error that contains a referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:routing_errors_without_referer]}
        get "/incorrect_route"
        ErrorMessage.count.should == 0
      end

      it "should store a routing error that has a referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:routing_errors_without_referer]}
        get "/incorrect_route", {}, {'HTTP_REFERER' => 'http://example.com'}
        ErrorMessage.count.should == 1
      end

      it "should store a non routing error without referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:routing_errors_without_referer]}
        get "/home/view_error"
        ErrorMessage.count.should == 1
      end
    end

    describe ":user_agent_regxp" do
      it "should not store the error message when the user agent matches this regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [:user_agent_regxp => /\b(NaughtyBot)\b/]}
        get "/incorrect_route", {}, {'HTTP_USER_AGENT' => 'I am a NaughtyBot'}
        ErrorMessage.count.should == 0
      end

      it "should store the error message when the user agent doesnt match this regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [:user_agent_regxp => /\b(NaughtyBot)\b/]}
        get "/incorrect_route", {}, {'HTTP_USER_AGENT' => "Mozilla/5.0 (Windows NT 6.1; rv:5.0) Gecko/20100101 Firefox/5.0"}
        ErrorMessage.count.should == 0
      end
    end

    describe ":target_url_regxp" do
      it "should not store the error message when the url matches this regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [:target_url_regxp => /\b(incorrect)\b/]}
        get "/incorrect_route"
        ErrorMessage.count.should == 0
      end

      it "should store the error message when the url doesnt matche this regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [:target_url_regxp => /\b(phpMyAdmin)\b/]}
        get "/incorrect_route"
        ErrorMessage.count.should == 1
      end
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
