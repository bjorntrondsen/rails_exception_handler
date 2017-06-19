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
      if rails_42_or_higher?
        response[2].class.should == ActionDispatch::Response::RackBody # body
      else
        response[2].class.should == ActionDispatch::Response # body
      end
    end

    it "should set the response code to 404 on routing errors" do
      exception = create_exception
      exception.stub(:class => ActionController::RoutingError)
      handler = RailsExceptionHandler::Handler.new(create_env, exception)
      response = handler.handle_exception
      response.length.should == 3
      response[0].should == 404
    end
  end

  describe '.response' do
    it "should call index action on ErrorResponseController" do
      ErrorResponseController.should_receive(:action).with(:index).and_return(double(Object, :call => [500, {}, {}]))
      @handler.handle_exception
    end

    it "should set response_code to '404' on routing errors" do
      exception = create_exception
      env = create_env
      exception.stub(:class => ActiveRecord::RecordNotFound)
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
      if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0
        env['exception_handler.layout'].should == 'application'
      else
        env['exception_handler.layout'].should == 'layouts/application'
      end
    end

    it "should use the fallback layout when no layout is defined" do
      env = create_env(:target => '/routing_error')
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      handler.instance_variable_set("@controller",double(Object, :_default_layout => nil))
      handler.handle_exception
      env['exception_handler.layout'].should == 'fallback'
    end

    it "should use public/404.html on routing errors if the file exists" do
      create_static_error_pages
      exception = create_exception
      env = create_env
      exception.stub(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(env, exception)
      response = handler.handle_exception
      if rails_42_or_higher?
        response[2].should == ["content of 404.html"]
      else
        response[2].body.should == "content of 404.html"
      end
    end

    it "should use public/500.html on non-routing errors if the file exists" do
      create_static_error_pages
      env = create_env
      handler = RailsExceptionHandler::Handler.new(env, create_exception)
      response = handler.handle_exception
      if rails_42_or_higher?
        response[2].should == ["content of 500.html"]
      else
        response[2].body.should == "content of 500.html"
      end
    end
  end

  describe '.response_layout' do
    it "should not set a layout for XHR requests" do
      handler = RailsExceptionHandler::Handler.new(create_env, create_exception)
      handler.handle_exception
      request = handler.instance_variable_get(:@request)
      request.stub(:xhr? => true)
      handler.instance_variable_set(:@request, request)
      handler.send(:response_layout).should == false
    end

    it "should use the controllers default layout if it exists" do
      handler = RailsExceptionHandler::Handler.new(create_env(:target => '/routing_error'), create_exception)
      handler.handle_exception
      if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0
        handler.send(:response_layout).should == 'application'
      else
        handler.send(:response_layout).should == 'layouts/application'
      end
    end

    it "should use the fallback layout if the controller does not have a default layout" do
      env = create_env
      controller = ApplicationController.new
      controller.stub(:_default_layout => 'fallback')
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
      exception.stub(:class => ActiveRecord::RecordNotFound)
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
      exception.stub(:class => ActiveRecord::RecordNotFound)
      handler = RailsExceptionHandler::Handler.new(env, exception)
      handler.handle_exception
      handler.send(:response_text).should == 'Default response'
    end
  end
end
