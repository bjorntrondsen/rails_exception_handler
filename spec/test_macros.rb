
require 'fileutils'

module TestMacros
  def app # Used by by Rack::Test to get the application object
    Rails.application.app
  end

  def create_env(*args)
    options = args.extract_options!
    referer = options[:referer] || 'http://google.com/'
    target = options[:target] || '/home'
    s = Rack::Test::Session.new(nil)
    env = s.send(:env_for, target, {:params => {:foo => 'bar'}, 'HTTP_REFERER' => referer, 'HTTP_USER_AGENT' => "Mozilla/4.0 (compatible; MSIE 8.0)"})
  end

  def create_parser(exception = nil, request = nil, controller = nil)
      env = create_env
      controller ||= mock(ApplicationController, :current_user => mock(Object, :login => 'matz'))
      request ||= ActionDispatch::Request.new(env)
      exception ||= create_exception
      parser = RailsExceptionHandler::Parser.new(env, request, exception, controller)
  end

  def create_exception
    exception = nil
    begin
      nil.foo
    rescue Exception => e
      exception = e
    end
  end

  def clear_test_log
    File.open(log_path, 'w') {|f| f.write('') }
  end

  def read_test_log
    data = ""
    File.open(log_path, 'r').each_line do |line|
      data += line + '\n'
    end
    return data
  end

  def reset_configuration
    Rails.configuration.middleware.delete(RailsExceptionHandler)
    RailsExceptionHandler.configure do |config|
      config.storage_strategies = [:active_record]
      config.environments = [:test]
      config.store_user_info = false
      config.filters = []
      config.fallback_layout = 'fallback'
      config.response_mapping = {}
      config.responses = { :default => '<h1>Internal server error</h1><p>The application has encountered an unexpected issue.</p>' }
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
      config.store_global_info do |storage|
        storage[:app_name] =     Rails.application.class.parent_name
        storage[:created_at] =   Time.now
      end
    end
  end

  private

  def log_path
    File.expand_path(File.dirname(__FILE__)) + "/#{TEST_APP}/log/test.log"
  end
end
