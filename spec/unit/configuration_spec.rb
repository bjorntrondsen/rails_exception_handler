require 'spec_helper'

describe RailsExceptionHandler::Configuration do
  describe ".initialize" do
    before(:each) do
      @configuration = RailsExceptionHandler::Configuration.new
    end

    it "should add :production to environments" do
      @configuration.environments.should == [:production]
    end

    it "should set storage_strategies to []" do
      @configuration.storage_strategies.should == []
    end

    it "should set store_user_info to false" do
      @configuration.store_user_info = false
    end

    it "should set filters to [] " do
      @configuration.filters.should == []
    end

    it "should initialize responses to an empty hash" do
      @configuration.responses.should == {}
    end

    it "should set the reponse_mapping to {}" do
      @configuration.response_mapping.should == {}
    end

    it "should set the fallback layout to 'application'" do
      @configuration.fallback_layout.should == 'application'
    end
  end

  # Internal and external info
  # Specs per block
  # Not fail if block is not configured
end


config.store_request_info do |storage,request|
  storage[:target_url] =  request.url
  storage[:referer_url] = request.referer
  storage[:params] =      request.params.inspect
  storage[:user_agent] =  request.user_agent
end
config.store_exception_info do |storage,exception|
  storage[:class_name] =   exception.class.to_s
  storage[:message] =      exception.to_s
  storage[:trace] =        exception.backtrace.join("\n")
end
config.store_environment_info do |storage,env|
end
config.store_global_info do |storage|
  storage[:app_name] =     Rails.application.class.parent_name
  storage[:created_at] =   Time.now
end
