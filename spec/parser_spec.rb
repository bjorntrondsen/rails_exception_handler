require File.expand_path(File.dirname(__FILE__)) + '/spec_helper.rb'

describe RailsExceptionHandler::Parser do
  describe ".relevant_info" do
    it "should return app_name"
    it "should return class_name"
    it "should return message"
    it "should return trace"
    it "should return target_url"
    it "should return referer_url"
    it "should return params"
    it "should return user_agent"
    it "should return user_info"
    it "should return created_at"
  end

  describe ".ignore?" do
    it "should return true on routing errors without referer"

    it "should return false on routing errors with referer"

    it "should return false on non-routing erros without referer"

    it "should return true on requests who has a user_agent string that contains a bot pattern"
  end

  describe "routing_error?" do
    it "should return true on ActionController::RoutingError"

    it "should return true on AbstractController::ActionNotFound"

    it "should return true on ActiveRecord::RecordNotFound"
  end

  describe "user_info" do
    it "should return nil when the controller has no current_user method"

    it "should return login field if it exists"

    it "should return the username field if it exists"
    
    it "should return the email filed if it exists"
  end
end
