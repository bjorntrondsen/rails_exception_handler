require 'spec_helper'

describe RailsExceptionHandler::Handler do
  before(:each) do
    @handler = RailsExceptionHandler::Handler.new(create_env, create_exception)
  end

  describe ".handle_exception" do
    it "should parse error" do
      @handler.handle_exception
      @handler.instance_variable_get(:@parsed_error).should_not == nil
    end

    it "should store error" do
      @handler.should_receive(:store_error)
      @handler.handle_exception
    end

    it "should return a rack tripple" do
      response = @handler.handle_exception
      response.length.should == 3
      response[0].should == 500 # response code
      response[1].class.should == Hash # headers
      response[2].class.should == ActionDispatch::Response # body
    end

    it "should set the response code to 404 on routing errors" do
      exception = create_exception
      exception.stub!(:class => ActionController::RoutingError)
      handler = RailsExceptionHandler::Handler.new(create_env, exception)
      response = handler.handle_exception
      response.length.should == 3
      response[0].should == 404
    end
  end

  describe ".store_error" do
    it "should store an error message in the database when storage_strategies includes :active_record" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:active_record] }
      @handler.handle_exception
      ErrorMessage.count.should == 1
      msg = ErrorMessage.first
      msg.app_name.should ==      'ExceptionHandlerTestApp'
      msg.class_name.should ==    'NoMethodError'
      msg.message.should ==       "undefined method `foo' for nil:NilClass"
      msg.trace.should match      /spec\/test_macros\.rb:28/
      msg.params.should match     /\"foo\"=>\"bar\"/
      msg.user_agent.should ==    'Mozilla/4.0 (compatible; MSIE 8.0)'
      msg.target_url.should ==    'http://example.org/home?foo=bar'
      msg.referer_url.should ==   'http://google.com/'
      msg.created_at.should be >  5.seconds.ago
      msg.created_at.should be <  Time.now
    end

    it "should not store an error message in the database when storage_strategies does not include :active_record" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      ErrorMessage.count.should == 0
    end

    it "it should log an error to the rails log when storage_strategies includes :rails_log" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:rails_log] }
      read_test_log.should == ''
      @handler.handle_exception
      read_test_log.should match /NoMethodError \(undefined method `foo' for nil:NilClass\)/
      read_test_log.should match /spec\/test_macros\.rb:28/
      read_test_log.should match /PARAMS:\s+\{\"foo\"=>\"bar\"\}/
      read_test_log.should match /USER_AGENT:\s+Mozilla\/4.0 \(compatible; MSIE 8\.0\)/
      read_test_log.should match /TARGET:\s+http:\/\/example\.org\/home\?foo=bar/
      read_test_log.should match /REFERER:\s+http:\/\/google\.com\//
    end

    it "should not log an error to the rails log when storage_strategies does not include :rails_log" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      read_test_log.should == ''
      @handler.handle_exception
      read_test_log.should == ''
    end

    it "should send the error_message as an HTTP POST request when :remote_url is included" do
      Time.stub!(:now => Time.now) # Otherwise the timestamps will be different, and comparison fail
      @handler.handle_exception
      parser = @handler.instance_variable_get(:@parsed_error)
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:remote_url => {:target => 'http://example.com/error_messages'}] }
      uri = URI.parse('http://example.com/error_messages')
      params = {}
      parser.external_info.each do |key,value|
        params["error_message[#{key}]"] = value
      end
      Net::HTTP.should_receive(:post_form).with(uri, params)
      @handler.handle_exception
    end

    it "should not send the error_message as an HTTP POST request when :remote_url is not included" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      Net::HTTP.should_not_receive(:post_form)
      @handler.handle_exception
    end

    it "should be able to use multiple storage strategies" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:active_record, :rails_log] }
      read_test_log.should == ''
      @handler.handle_exception
      read_test_log.should match /NoMethodError \(undefined method `foo' for nil:NilClass\)/
      ErrorMessage.count.should == 1
    end
  end

  describe '.response' do
    it "should call index action on ErrorResponseController" do
      ErrorResponseController.should_receive(:action).with(:index).and_return(mock(Object, :call => [500, {}, {}]))
      @handler.handle_exception
    end

    it "should set response_code to '404' on routing errors" do
      exception = create_exception
      env = create_env
      exception.stub!(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(env, exception)
      response = handler.handle_exception
      response[0].should == 404
    end

    it "should set response_code to '500' on all other errors" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      response = handler.handle_exception
      response[0].should == 500
    end

    it "should save the layout in env" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.handle_exception
      if TEST_APP == 'dummy_32'
        env['exception_handler.layout'].should == 'layouts/application'
      else
        env['exception_handler.layout'].should == 'application'
      end
    end

    it "should use the fallback layout when no layout is defined" do
      env = create_env(:target => '/routing_error')
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.instance_variable_set("@controller",mock(Object, :_default_layout => nil))
      handler.handle_exception
      env['exception_handler.layout'].should == 'fallback'
    end
  end

  describe '.response_layout' do
    it "should not set a layout for XHR requests" do
      handler = RailsExceptionHandler::Handler.new(create_env, create_exception)
      handler.handle_exception
      request = handler.instance_variable_get(:@request)
      request.stub!(:xhr? => true)
      handler.instance_variable_set(:@request, request)
      handler.send(:response_layout).should == false
    end

    it "should use the controllers default layout if it exists" do
      handler = RailsExceptionHandler::Handler.new(create_env(:target => '/routing_error'), create_exception)
      handler.handle_exception
      if TEST_APP == 'dummy_32'
        handler.send(:response_layout).should == 'layouts/application'
      else
        handler.send(:response_layout).should == 'application'
      end
    end

    it "should use the fallback layout if the controller does not have a default layout" do
      env = create_env
      controller = ApplicationController.new
      controller.stub!(:_default_layout => 'fallback')
      env['action_controller.instance'] = controller
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.handle_exception
      handler.send(:response_layout).should == 'fallback'
    end
  end

  describe '.response_text' do
    it "should return the response mapped to the exception class if it exists" do
      RailsExceptionHandler.configure { |config|
        config.responses[:not_found] = 'Page not found'
        config.response_mapping = {'ActiveRecord::RecordNotFound' => :not_found}
      }
      env = create_env
      exception = create_exception
      exception.stub!(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(env, exception)
      handler.handle_exception
      handler.send(:response_text).should == 'Page not found'
    end

    it "should return the default response if a mapping does not exist" do
      RailsExceptionHandler.configure { |config|
        config.responses[:default] = 'Default response'
        config.response_mapping = {}
      }
      env = create_env
      exception = create_exception
      exception.stub!(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(env, exception)
      handler.handle_exception
      handler.send(:response_text).should == 'Default response'
    end
  end
end
