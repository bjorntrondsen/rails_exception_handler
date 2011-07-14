require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe RailsExceptionHandler::Parser do
  before(:each) do
    env = create_env
    controller = mock(ApplicationController, :current_user => mock(Object, :login => 'superman'))
    request = ActionDispatch::Request.new(env)
    @parser = RailsExceptionHandler::Parser.new(create_exception, request, controller)
  end

  describe ".relevant_info" do
    it("should return app_name") { @parser.relevant_info[:app_name].should == 'ExceptionHandlerTestApp' }
    it("should return class_name") { @parser.relevant_info[:class_name].should == 'NoMethodError' }
    it("should return message") { @parser.relevant_info[:message].should == "undefined method `foo' for nil:NilClass" }
    it("should return trace") { @parser.relevant_info[:trace].should match /active_support\/whiny_nil/ }
    it("should return target_url") { @parser.relevant_info[:target_url].should == 'http://example.org/home?foo=bar' }
    it("should return referer_url") { @parser.relevant_info[:referer_url].should == 'http://google.com/' }
    it("should return params") { @parser.relevant_info[:params].should match(/\"foo\"=>\"bar\"/) }
    it("should return user_agent") { @parser.relevant_info[:user_agent].should == "Mozilla/4.0 (compatible; MSIE 8.0)" }
    it("should return user_info") { @parser.relevant_info[:user_info].should == 'superman' }
    it("should return created_at") { @parser.relevant_info[:created_at].should be > 5.seconds.ago }
    it("should return created_at") { @parser.relevant_info[:created_at].should be < Time.now }
  end

  describe ".ignore?" do
    context "routing errors" do
      it "should return true on routing errors when the filter contains :all_routing_errors" do
        RailsExceptionHandler.configure { |config| config.filters = [:all_routing_errors] }
        exception = create_exception
        exception.stub!(:class => ActionController::RoutingError)
        parser = create_parser(exception, nil, nil)
        parser.ignore?.should == true
      end

      it "should return true on routing errors without referer when the filter contains :routing_errors_without_referer" do
        RailsExceptionHandler.configure { |config| config.filters = [:routing_errors_without_referer] }
        exception = create_exception
        exception.stub!(:class => ActionController::RoutingError)
        parser = create_parser(exception, nil, nil)
        parser.ignore?.should == true
      end

      it "should return true when the user agent matches against the filters :user_agent_regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [{:user_agent_regxp => /\b(Mozilla)\b/}] }
        parser = create_parser(nil, nil, nil)
        parser.ignore?.should == true
      end

      it "should return true when the url matches against the filters :target_url_regxp" do
        RailsExceptionHandler.configure { |config| config.filters = [{:target_url_regxp => /\b(home)\b/}] }
        parser = create_parser(nil, nil, nil)
        parser.ignore?.should == true
      end

      it "should return false when the request is not caught by a filter" do
        RailsExceptionHandler.configure { |config| config.filters = [] }
        parser = create_parser(nil, nil, nil)
        parser.ignore?.should == false
      end
    end

    context "crawlers" do
      it "should return true on errors created by a crawler when ignore_crawlers is set to true" do
        RailsExceptionHandler.configure { |config| config.ignore_crawlers = true }
        request = ActionDispatch::Request.new(create_env)
        request.stub!(:user_agent => 'foo Slurp bar')
        parser = create_parser(nil, request, nil)
        parser.ignore?.should == true
      end

      it "should return false on errors created by a crawler when ignore_crawlers is set to false" do
        RailsExceptionHandler.configure { |config| config.ignore_crawlers = false }
        request = ActionDispatch::Request.new(create_env)
        request.stub!(:user_agent => 'foo Slurp bar')
        parser = create_parser(nil, request, nil)
        parser.ignore?.should == false
      end

      it "should return false on errors not created by a crawler when ignore_crawlers is set to true" do
        RailsExceptionHandler.configure { |config| config.ignore_crawlers = true }
        parser = create_parser(nil, nil, nil)
        parser.ignore?.should == false
      end
    end
  end

  describe ".crawler?" do
    it "should return true on requests who has a user_agent string that contains a bot pattern" do
      env = create_env
      request = ActionDispatch::Request.new(env)
      request.stub!(:user_agent => 'foo Slurp bar')
      parser = create_parser(nil, request, nil)
      parser.send(:crawler?).should == true
    end

    it "should return false on requests that does not have a user agent that contains a bot pattern" do
      parser = create_parser(nil, nil, nil)
      parser.send(:crawler?).should == false
    end
  end

  describe "routing_error?" do
    it "should return true on ActionController::RoutingError" do
      exception = create_exception
      exception.stub!(:class => ActionController::RoutingError)
      parser = create_parser(exception, nil, nil)
      parser.routing_error?.should == true
    end

    it "should return true on AbstractController::ActionNotFound" do
      exception = create_exception
      exception.stub!(:class => AbstractController::ActionNotFound)
      parser = create_parser(exception, nil, nil)
      parser.routing_error?.should == true
    end

    it "should return true on ActiveRecord::RecordNotFound" do
      exception = create_exception
      exception.stub!(:class => ActiveRecord::RecordNotFound)
      parser = create_parser(exception, nil, nil)
      parser.routing_error?.should == true
    end

    it "should return false on all other errors" do
      @parser.routing_error?.should == false
    end
  end

  describe "user_info" do
    it "should return nil when the controller has no current_user method" do
      controller = mock(Object)
      parser = create_parser(nil, nil, controller)
      parser.send(:user_info).should == nil
    end

    it "should return login field if it exists" do
      controller = mock(Object, :current_user => mock(Object, :login => 'bob'))
      parser = create_parser(nil, nil, controller)
      parser.send(:user_info).should == 'bob'
    end

    it "should return the username field if it exists" do
      controller = mock(Object, :current_user => mock(Object, :username => 'tom'))
      parser = create_parser(nil, nil, controller)
      parser.send(:user_info).should == 'tom'
    end
    
    it "should return the email filed if it exists" do
      controller = mock(Object, :current_user => mock(Object, :email => 'me@example.com'))
      parser = create_parser(nil, nil, controller)
      parser.send(:user_info).should == 'me@example.com'
    end
  end
end
