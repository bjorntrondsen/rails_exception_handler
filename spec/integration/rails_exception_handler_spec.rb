require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper.rb'

describe RailsExceptionHandler do
  it "should catch controller errors" do
    get "/home/controller_error"
    ErrorMessage.count.should == 1
    last_response.body.should match(/Internal server error/)
    ErrorMessage.first.class_name.should == 'NoMethodError'
  end

  it "should catch model errors" do
    get "/home/model_error"
    ErrorMessage.count.should == 1
    last_response.body.should match(/Internal server error/)
    ErrorMessage.first.class_name.should == 'NoMethodError'
  end

  it "should catch view errors" do
    get "/home/view_error"
    ErrorMessage.count.should == 1
    last_response.body.should match(/Internal server error/)
    ErrorMessage.first.class_name.should == 'ActionView::Template::Error'
  end

  it "should catch routing errors"  do
    get "/incorrect_route"
    ErrorMessage.count.should == 1
    last_response.body.should match(/Page not found/)
    ErrorMessage.first.class_name.should == 'ActionController::RoutingError'
  end

  it "should catch syntax errors" do
    get "/home/syntax_error"
    ErrorMessage.count.should == 1
    last_response.body.should match(/Internal server error/)
    ErrorMessage.first.class_name.should == 'SyntaxError'
  end

  it "should append the failed controllers view layout when rendering the response" do
    get "/home/view_error"
    last_response.body.should match(/this_is_the_home_layout/)
  end

  it "should fall back to using the application layout on routing errors" do
    get "/incorrect_route"
    last_response.body.should match(/this_is_the_fallback_layout/)
  end

  it "should store the correct information in the database" do
    RailsExceptionHandler.configure { |config| config.store_user_info = {:method => :current_user, :field => :login} }
    get "/home/controller_error", {}, {'HTTP_REFERER' => 'http://google.com/', 'HTTP_USER_AGENT' => 'Mozilla/4.0 (compatible; MSIE 8.0)'}
    ErrorMessage.count.should == 1
    msg = ErrorMessage.first
    msg.app_name.should ==      'ExceptionHandlerTestApp'
    msg.class_name.should ==    'NoMethodError'
    msg.message.should ==       "undefined method `foo' for nil:NilClass"
    msg.trace.should match      /exception_handler_test_app\/app\/controllers\/home_controller.rb:5:in `controller_error'/
    msg.params.should match     /"controller"=>"home"/
    msg.params.should match     /"action"=>"controller_error"/
    msg.user_agent.should ==    'Mozilla/4.0 (compatible; MSIE 8.0)'
    msg.target_url.should ==    'http://example.org/home/controller_error'
    msg.referer_url.should ==   'http://google.com/'
    msg.user_info.should ==     'matz'
    msg.created_at.should be >  5.seconds.ago
    msg.created_at.should be <  Time.now
  end
end
