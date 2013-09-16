require 'spec_helper'

describe RailsExceptionHandler::Parser do
  before(:each) do
    env = create_env
    controller = double(ApplicationController, :current_user => double(Object, :login => 'matz'))
    request = ActionDispatch::Request.new(env)
    @parser = RailsExceptionHandler::Parser.new(env, request, create_exception, controller)
  end

  describe ".external_info" do
    it("should return app_name") { @parser.external_info[:app_name].should == 'ExceptionHandlerTestApp' }
    it("should return class_name") { @parser.external_info[:class_name].should == 'NoMethodError' }
    it("should return message") { @parser.external_info[:message].should == "undefined method `foo' for nil:NilClass" }
    it("should return trace") { @parser.external_info[:trace].should match /spec\/test_macros\.rb:28/ }
    it("should return target_url") { @parser.external_info[:target_url].should == 'http://example.org/home?foo=bar' }
    it("should return referer_url") { @parser.external_info[:referer_url].should == 'http://google.com/' }
    it("should return params") { @parser.external_info[:params].should match(/\"foo\"=>\"bar\"/) }
    it("should return user_agent") { @parser.external_info[:user_agent].should == "Mozilla/4.0 (compatible; MSIE 8.0)" }
    it("should return user_info") { @parser.external_info[:user_info].should == nil }
    it("should return created_at") { @parser.external_info[:created_at].should be > 5.seconds.ago }
    it("should return created_at") { @parser.external_info[:created_at].should be < Time.now }
  end

  describe ".ignore?" do
    context "routing errors" do
      it "should return true on routing errors when the filter contains :all_404s" do
        RailsExceptionHandler.configure { |config| config.filters = [:all_404s] }
        exception = create_exception
        exception.stub(:class => ActionController::RoutingError)
        parser = create_parser(exception, nil, nil)
        parser.ignore?.should == true
      end

      it "should return true on routing errors without referer when the filter contains :no_referer_404s" do
        RailsExceptionHandler.configure { |config| config.filters = [:no_referer_404s] }
        exception = create_exception
        exception.stub(:class => ActionController::RoutingError)
        request = ActionDispatch::Request.new(create_env(:referer => '/'))
        parser = create_parser(exception, request, nil)
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
  end

  describe "routing_error?" do
    it "should return true on ActionController::RoutingError" do
      exception = create_exception
      exception.stub(:class => ActionController::RoutingError)
      parser = create_parser(exception, nil, nil)
      parser.routing_error?.should == true
    end

    it "should return true on AbstractController::ActionNotFound" do
      exception = create_exception
      exception.stub(:class => AbstractController::ActionNotFound)
      parser = create_parser(exception, nil, nil)
      parser.routing_error?.should == true
    end

    it "should return true on ActiveRecord::RecordNotFound" do
      exception = create_exception
      exception.stub(:class => ActiveRecord::RecordNotFound)
      parser = create_parser(exception, nil, nil)
      parser.routing_error?.should == true
    end

    it "should return false on all other errors" do
      @parser.routing_error?.should == false
    end
  end

  describe "user_info" do
    it "should store user info based on the method and field provided" do
      RailsExceptionHandler.configure {|config| config.store_user_info = {:method => :current_user, :field => :login}}
      controller = double(ApplicationController, :current_user => double(Object, :login => 'matz'))
      parser = create_parser(nil, nil, controller)
      parser.external_info[:user_info].should == 'matz'
    end
    it "should store 'Anonymous' when store_user_info is enabled and no user is logged in" do
      RailsExceptionHandler.configure {|config| config.store_user_info = {:method => :current_user, :field => :login}}
      controller = double(ApplicationController, :current_user => nil)
      parser = create_parser(nil, nil, controller)
      parser.external_info[:user_info].should == 'Anonymous'
    end

    it "should not store any info when configured store_user_info is false" do
      RailsExceptionHandler.configure {|config| config.store_user_info = false}
      controller = double(ApplicationController, :current_user => double(Object, :login => 'matz'))
      parser = create_parser(nil, nil, controller)
      parser.external_info[:user_info].should == nil
    end
  end

  describe "anon_user?" do
    it "should return true if user_info is nil" do
      RailsExceptionHandler.configure {|config| config.store_user_info = false}
      controller = double(ApplicationController)
      parser = create_parser(nil, nil, controller)
      parser.anon_user?.should be_true
    end

    it "should return true if user_info is 'Anonymous'" do
      RailsExceptionHandler.configure {|config| config.store_user_info = {:method => :current_user, :field => :login}}
      controller = double(ApplicationController, :current_user => nil)
      parser = create_parser(nil, nil, controller)
      parser.external_info[:user_info].should == 'Anonymous'
      parser.anon_user?.should be_true
    end

    it "should return false if user info is present" do
      RailsExceptionHandler.configure {|config| config.store_user_info = {:method => :current_user, :field => :login}}
      controller = double(ApplicationController, :current_user => double(Object, :login => 'matz'))
      parser = create_parser(nil, nil, controller)
      parser.anon_user?.should be_false
    end
  end
end
