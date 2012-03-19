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

end
