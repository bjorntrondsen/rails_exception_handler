require File.expand_path(File.dirname(__FILE__)) + '/spec_helper.rb'

describe RailsExceptionHandler::Handler do
  before(:each) do
    @handler = RailsExceptionHandler::Handler.new(create_env, create_exception)
  end

  describe ".handle_exception" do
    it "should store an error message in the database" do
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

    it "should log an error to the log file" do
      @handler.should_receive(:log_error)
      @handler.handle_exception
    end
  end

  describe ".log_error" do
    it "should log an error in the correct format" do
      ActiveRecord::Base.logger = nil
      ActionController::Base.logger = nil 
      @handler.handle_exception
      read_test_log.should match /NoMethodError \(undefined method `foo' for nil:NilClass\)/
      read_test_log.should match /lib\/active_support\/whiny_nil\.rb:48/
    end
  end

  describe '.response' do
    it "should call err404 on routing errors" do
      exception = create_exception
      exception.stub!(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(create_env, exception)
      ErrorResponseController.should_receive(:action).with(:err404).and_return(mock(Object, :call => true))
      handler.handle_exception
    end

    it "should call err500 on all other errors" do
      ErrorResponseController.should_receive(:action).with(:err500).and_return(mock(Object, :call => true))
      @handler.handle_exception
    end

    it "should save the layout in env" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.instance_variable_set("@controller",mock(Object, :_default_layout => 'home'))
      handler.handle_exception
      env['layout_for_exception_response'].should == 'home'
    end

    it "should use the fallback layout when no layout is defined" do
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.handle_exception
      env['layout_for_exception_response'].should == 'application'
    end
  end
end
