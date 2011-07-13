require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

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
      response[0].should == 200 # response code
      response[1].class.should == Hash # headers
      response[2].class.should == ActionDispatch::Response # body
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
      msg.trace.should match      /active_support\/whiny_nil/
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
      read_test_log.should match /lib\/active_support\/whiny_nil\.rb:48/
      read_test_log.should match /PARAMS:\s+{\"foo\"=>\"bar\"}/
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
      params = {:error_message => parser.relevant_info}
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
      ErrorResponseController.should_receive(:action).with(:index).and_return(mock(Object, :call => true))
      @handler.handle_exception
    end

    it "should set response_code to '404' on routing errors" do
      exception = create_exception
      env = create_env
      exception.stub!(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(env, exception)
      handler.handle_exception
      env['exception_handler.response_code'].should == '404'
    end

    it "should set response_code to '500' on all other errors" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.handle_exception
      env['exception_handler.response_code'].should == '500'
    end

    it "should save the layout in env" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.instance_variable_set("@controller",mock(Object, :_default_layout => 'home'))
      handler.handle_exception
      env['exception_handler.layout'].should == 'home'
    end

    it "should use the fallback layout when no layout is defined" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.handle_exception
      env['exception_handler.layout'].should == 'application'
    end
  end
end
