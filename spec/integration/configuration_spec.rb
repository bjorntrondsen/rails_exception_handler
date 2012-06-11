require 'spec_helper'

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
      read_test_log.should match /undefined method `foo' for nil:NilClass/
      if TEST_APP == 'dummy_32'
        read_test_log.should match /action_controller\/metal\/implicit_render\.rb:4/
      else
        read_test_log.should match /lib\/active_support\/whiny_nil\.rb:48/
      end
      read_test_log.should match /PARAMS:\s+\{/
      read_test_log.should match /TARGET_URL: http:\/\/example\.org\/home\/model_error/
    end

    # No idea how to integration test remote_url without spawning a dedicated test server (use VCR?)
  end

  describe '.filters' do
    describe ":all_404s" do
      it "should ignore routing errors when the filters contains :all_404s" do
        RailsExceptionHandler.configure { |config| config.filters = [:all_404s]}
        get('/incorrect_route')
        ErrorMessage.count.should == 0
      end

      it "should not ignore routing errors when the filters doesnt contain :all_404s" do
        RailsExceptionHandler.configure { |config| config.filters = []}
        get('/incorrect_route')
        ErrorMessage.count.should == 1
      end
    end

    describe ":no_referer_404s" do
      it "should not store a routing error that contains a referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:no_referer_404s]}
        get "/incorrect_route"
        ErrorMessage.count.should == 0
      end

      it "should store a routing error that has a referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:no_referer_404s]}
        get "/incorrect_route", {}, {'HTTP_REFERER' => 'http://example.com'}
        ErrorMessage.count.should == 1
      end

      it "should store a non routing error without referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:no_referer_404s]}
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
        ErrorMessage.count.should == 1
      end
    end

    describe ":target_url_regxp" do
      it "should not store the error message when the url matches this regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [:target_url_regxp => /incorrect/]}
        get "/incorrect_route"
        ErrorMessage.count.should == 0
      end

      it "should store the error message when the url doesnt matche this regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [:target_url_regxp => /\b(phpMyAdmin)\b/]}
        get "/incorrect_route"
        ErrorMessage.count.should == 1
      end
    end

    describe ":anon_404s" do
      it "should log a 404 from a logged in user" do
        RailsExceptionHandler.configure do |config|
          config.environments = [Rails.env.to_sym]
          config.storage_strategies = [:active_record]
          config.store_user_info = {:method => :current_user, :field => :login}
          config.filters = [:anon_404s]
        end
        RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
        get "/incorrect_route"
        ErrorMessage.count.should == 1
      end

      it "should filter 404s from anonymous users" do
        RailsExceptionHandler.configure do |config|
          config.environments = [Rails.env.to_sym]
          config.storage_strategies = [:active_record]
          config.store_user_info = {:method => :nil_user, :field => :login}
          config.filters = [:anon_404s]
        end
        RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
        get "/incorrect_route"
        ErrorMessage.count.should == 0
      end

      it "should not filter 500s from anonymous users" do
        RailsExceptionHandler.configure do |config|
          config.environments = [Rails.env.to_sym]
          config.storage_strategies = [:active_record]
          config.store_user_info = {:method => :nil_user, :field => :login}
          config.filters = [:anon_404s]
        end
        RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
        get "/home/model_error"
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
      pending "Must find new way to unhook the exception handler here"
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
      last_response.body.should match(/this_is_the_application_layout/)
    end

    it "should log regular errors if the rails environment is included" do
      Rails.configuration.middleware.delete RailsExceptionHandler
      RailsExceptionHandler.configure { |config| config.environments = [Rails.env.to_sym] }
      get('/home/model_error')
      ErrorMessage.count.should == 1
      last_response.body.should match(/this_is_the_application_layout/)
    end
  end

  describe ".fallback_layout" do
    it "should use the supplied layout on routing errors" do
      RailsExceptionHandler.configure { |config| config.fallback_layout = 'home' }
      get('/incorrect_route')
      last_response.body.should match(/this_is_the_application_layout/)
    end
  end

  describe ".store_user_info" do
    it "should not store user info when disbled" do
      RailsExceptionHandler.configure do |config|
        config.environments = [Rails.env.to_sym]
        config.storage_strategies = [:active_record]
        config.store_user_info = nil
      end
      RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
      get('/incorrect_route')
      ErrorMessage.count.should == 1
      ErrorMessage.first.user_info.should == nil
    end

    it "should store user info on routing errors" do
      RailsExceptionHandler.configure do |config|
        config.environments = [Rails.env.to_sym]
        config.storage_strategies = [:active_record]
        config.store_user_info = {:method => :current_user, :field => :login}
      end
      RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
      RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
      get('/incorrect_route')
      ErrorMessage.count.should == 1
      ErrorMessage.first.user_info.should == 'matz'
    end

    it "should store user info on application errors" do
      RailsExceptionHandler.configure do |config|
        config.environments = [Rails.env.to_sym]
        config.storage_strategies = [:active_record]
        config.store_user_info = {:method => :current_user, :field => :login}
      end
      RailsExceptionHandler.configuration.instance_variable_set(:@whitelisted, false)
      get('/home/view_error')
      ErrorMessage.count.should == 1
      ErrorMessage.first.user_info.should == 'matz'
    end
  end

  describe "reponses and response_mapping" do
    it "should use the default response on non-mapped errors" do
      RailsExceptionHandler.configure do |config|
        config.environments = [Rails.env.to_sym]
        config.storage_strategies = []
        config.responses = {:default => 'Customized response'}
      end
      get('/home/view_error')
      last_response.body.should match(/Customized response/)
    end

    it "should use mapped response where they exist" do
      RailsExceptionHandler.configure do |config|
        config.environments = [Rails.env.to_sym]
        config.storage_strategies = []
        config.responses[:not_found] = 'custom_routing_response_text'
        config.response_mapping['ActionController::RoutingError'] = :not_found
      end
      get('/incorrect_route')
      last_response.body.should match(/custom_routing_response_text/)
    end
  end
end
