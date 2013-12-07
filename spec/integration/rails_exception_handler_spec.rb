require 'spec_helper'

describe RailsExceptionHandler do
  it "should catch controller errors" do
    get "/home/controller_error"
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
    last_response.body.should match(/Internal server error/)
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.class_name.should == 'NoMethodError'
    RailsExceptionHandler::Mongoid::ErrorMessage.first.class_name.should == 'NoMethodError' if defined?(Mongoid)
  end

  it "should catch model errors" do
    get "/home/model_error"
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
    last_response.body.should match(/Internal server error/)
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.class_name.should == 'NoMethodError'
    RailsExceptionHandler::Mongoid::ErrorMessage.first.class_name.should == 'NoMethodError' if defined?(Mongoid)
  end

  it "should catch view errors" do
    get "/home/view_error"
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
    last_response.body.should match(/Internal server error/)
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.class_name.should == 'ActionView::Template::Error'
    RailsExceptionHandler::Mongoid::ErrorMessage.first.class_name.should == 'ActionView::Template::Error' if defined?(Mongoid)
  end

  it "should catch routing errors"  do
    get "/incorrect_route"
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
    last_response.body.should match(/Internal server error/)
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.class_name.should == 'ActionController::RoutingError'
    RailsExceptionHandler::Mongoid::ErrorMessage.first.class_name.should == 'ActionController::RoutingError' if defined?(Mongoid)
  end

  it "should catch syntax errors" do
    get "/home/syntax_error"
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
    last_response.body.should match(/Internal server error/)
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.class_name.should == 'SyntaxError'
    RailsExceptionHandler::Mongoid::ErrorMessage.first.class_name.should == 'SyntaxError' if defined?(Mongoid)
  end

  it "should store the specified information in the database" do
    RailsExceptionHandler.configure { |config| config.store_user_info = {:method => :current_user, :field => :login} }
    get "/home/controller_error", {}, {'HTTP_REFERER' => 'http://google.com/', 'HTTP_USER_AGENT' => 'Mozilla/4.0 (compatible; MSIE 8.0)'}
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
    msgs = [RailsExceptionHandler::ActiveRecord::ErrorMessage.first]
    msgs << RailsExceptionHandler::Mongoid::ErrorMessage.first if defined?(Mongoid)
    msgs.each do |msg|
      msg.app_name.should ==      'ExceptionHandlerTestApp'
      msg.class_name.should ==    'NoMethodError'
      msg.message.should ==       "undefined method `foo' for nil:NilClass"
      msg.trace.should match      /#{TEST_APP}\/app\/controllers\/home_controller.rb:4:in `controller_error'/
      msg.params.should match     /"controller"=>"home"/
      msg.params.should match     /"action"=>"controller_error"/
      msg.user_agent.should ==    'Mozilla/4.0 (compatible; MSIE 8.0)'
      msg.target_url.should ==    'http://example.org/home/controller_error'
      msg.referer_url.should ==   'http://google.com/'
      msg.user_info.should ==     'matz'
      msg.server_name.should ==   'example.org'
      msg.remote_addr.should ==   '127.0.0.1'
      msg.created_at.should be >  5.seconds.ago
      msg.created_at.should be <  Time.now
    end
  end

  describe 'it should use the correct layout' do
    example '- application layout exists' do
      get "/home/controller_error"
      last_response.body.should match(/this_is_the_application_layout/)
    end

    example '- custom layout specified in render call' do
      pending "does not work"
      get "/home/custom_layout"
      last_response.body.should match(/this_is_the_custom_layout/)
    end

    example '- falling back when application layout doesn exist' do
      pending "must be tested manually"
      get "/incorrect_route"
      last_response.body.should match(/this_is_the_fallback_layout/)
    end
  end

end
