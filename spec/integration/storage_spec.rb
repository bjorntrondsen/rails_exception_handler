require 'spec_helper'

describe RailsExceptionHandler::Storage do
  render_views

  before(:each) do
    @handler = RailsExceptionHandler::Handler.new(create_env, create_exception)
  end

  it "should be able to use multiple storage strategies" do
    clear_test_log
    read_test_log.should == ''
    RailsExceptionHandler.configure { |config| config.storage_strategies = [:active_record, :mongoid, :rails_log] }
    @handler.handle_exception
    read_test_log.should match /undefined method `foo' for nil:NilClass/
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1 if defined?(Mongoid)
  end

  describe "active_record storage" do
    it "should store an error message in the database when storage_strategies includes :active_record" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:active_record] }
      @handler.handle_exception
      RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
      msg = RailsExceptionHandler::ActiveRecord::ErrorMessage.first
      msg.app_name.should ==      'ExceptionHandlerTestApp'
      msg.class_name.should ==    'NoMethodError'
      msg.message.should ==       "undefined method `foo' for nil:NilClass"
      msg.trace.should match      /spec\/test_macros\.rb:28/
      msg.params.should match     /\"foo\"=>\"bar\"/
      msg.user_agent.should ==    'Mozilla/4.0 (compatible; MSIE 8.0)'
      msg.target_url.should ==    'http://example.org/home?foo=bar'
      msg.referer_url.should ==   'http://google.com/'
      msg.created_at.should be >  5.seconds.ago
      msg.created_at.should be <  Time.now
    end

    it "should not store an error message in the database when storage_strategies does not include :active_record" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 0
    end
  end

  describe "mongoid storage" do
    it "should store an error message in the database when storage_strategies includes :mongoid" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:mongoid] }
      @handler.handle_exception
      if defined?(Mongoid)
        RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 1
        msg = RailsExceptionHandler::Mongoid::ErrorMessage.first
        msg.app_name.should ==      'ExceptionHandlerTestApp'
        msg.class_name.should ==    'NoMethodError'
        msg.message.should ==       "undefined method `foo' for nil:NilClass"
        msg.trace.should match      /spec\/test_macros\.rb:28/
        msg.params.should match     /\"foo\"=>\"bar\"/
        msg.user_agent.should ==    'Mozilla/4.0 (compatible; MSIE 8.0)'
        msg.target_url.should ==    'http://example.org/home?foo=bar'
        msg.referer_url.should ==   'http://google.com/'
        msg.created_at.should be >  5.seconds.ago
        msg.created_at.should be <  Time.now
      end
    end

    it "should not store an error message in the database when storage_strategies does not include :mongoid" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      RailsExceptionHandler::Mongoid::ErrorMessage.count.should == 0 if defined?(Mongoid)
    end
  end

  describe 'rails_log storage' do
    it "it should log an error to the rails log when storage_strategies includes :rails_log" do
      clear_test_log
      read_test_log.should == ''
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:rails_log] }
      @handler.handle_exception
      read_test_log.should match /undefined method `foo' for nil:NilClass/
      read_test_log.should match /spec\/test_macros\.rb:28/
      read_test_log.should match /PARAMS:\s+\{\"foo\"=>\"bar\"\}/
      read_test_log.should match /USER_AGENT:\s+Mozilla\/4.0 \(compatible; MSIE 8\.0\)/
      read_test_log.should match /TARGET_URL: http:\/\/example\.org\/home\?foo=bar/
      read_test_log.should match /REFERER_URL: http:\/\/google\.com\//
    end

    it "should not log an error to the rails log when storage_strategies does not include :rails_log" do
      clear_test_log
      read_test_log.should == ''
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      @handler.handle_exception
      if Rails::VERSION::MAJOR > 4
        read_test_log.should == "  Rendering html template within layouts/application\n\\n  Rendered html template within layouts/application (0.0ms)\n\\n"
      elsif Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR > 0
        read_test_log.should == "  Rendered text template within layouts/fallback (0.0ms)\n\\n"
      elsif Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 0
        read_test_log.should == "  Rendered text template within layouts/application (0.0ms)\n\\n"
      else
        read_test_log.should == ''
      end
    end
  end

  describe 'remote_url storage' do
    it "should send the error_message as an HTTP POST request when :remote_url is included" do
      Time.stub(:now => Time.now) # Otherwise the timestamps will be different, and comparison fail
      @handler.handle_exception
      parser = @handler.instance_variable_get(:@parsed_error)
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:remote_url => {:target => 'http://example.com/error_messages'}] }
      uri = URI.parse('http://example.com/error_messages')
      params = RailsExceptionHandler::Storage.send(:flatten_hash, { :error_message => parser.external_info })
      Net::HTTP.should_receive(:post_form).with(uri, params)
      @handler.handle_exception
    end

    it "should not send the error_message as an HTTP POST request when :remote_url is not included" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      Net::HTTP.should_not_receive(:post_form)
      @handler.handle_exception
    end
  end

  describe 'email storage' do
    it "should send the error_message as an email :email is included" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:email => {:recipients => "test@example.com"}] }
      @handler.handle_exception
      ActionMailer::Base.deliveries.length.should == 1
      email = ActionMailer::Base.deliveries.first
      email.to.should == ['test@example.com']
    end

    it "should not send the error_message as an email when :email is not included" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [] }
      @handler.handle_exception
      ActionMailer::Base.deliveries.length.should == 0
    end

    it "should not send to blank recipients" do
      [nil, "", [] ].each do |value|
        RailsExceptionHandler.configure { |config| config.storage_strategies = [:email => {:recipients => value}] }
        @handler.handle_exception
        ActionMailer::Base.deliveries.length.should == 0
      end
    end

    it "should allow multiple receivers" do
      RailsExceptionHandler.configure { |config| config.storage_strategies = [:email => {:recipients => "test@example.com,test2@example.com"}] }
      @handler.handle_exception
      ActionMailer::Base.deliveries.length.should == 1
      email = ActionMailer::Base.deliveries.first
      email.to.should == ['test@example.com','test2@example.com']
    end
  end
end
