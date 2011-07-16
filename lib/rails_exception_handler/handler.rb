class RailsExceptionHandler::Handler
  def initialize(env, exception)
    @exception = exception
    @env = env
    @request = ActionDispatch::Request.new(@env)
    @parsed_error = nil
    if(@env['action_controller.instance'])
      @controller = @env['action_controller.instance']
    else
      @controller = ApplicationController.new(@env)
      @controller.request = @request
    end
  end

  def handle_exception
    @parsed_error = RailsExceptionHandler::Parser.new(@exception, @request, @controller)
    store_error unless(@parsed_error.ignore?)
    return response
  end
  
  private

  def store_error
    RailsExceptionHandler.configuration.storage_strategies.each do |strategy|
      if(strategy.class == Symbol)
        send("store_in_#{strategy}")
      elsif(strategy.class == Hash && strategy[:remote_url])
        store_in_remote_url(strategy[:remote_url])
      else
        raise "RailsExceptionHandler: Unknown storage strategy #{strategy.inspect}"
      end
    end
  end

  def store_in_active_record
    ErrorMessage.create(@parsed_error.relevant_info)
  end

  def store_in_rails_log
    info = @parsed_error.relevant_info
    message  = "TARGET:     #{info[:target_url]}\n"
    message += "REFERER:    #{info[:referer_url]}\n"
    message += "PARAMS:     #{info[:params]}\n"
    message += "USER_AGENT: #{info[:user_agent]}\n"
    message += "USER_INFO:  #{info[:user_info]}\n"
    message += "#{info[:class_name]} (#{info[:message]}):\n"
    message += Rails.backtrace_cleaner.clean(info[:trace].split("\n"), :noise).join("\n")
    Rails.logger.fatal(message)
  end

  def store_in_remote_url(args)
    uri = URI.parse(args[:target])
    params = {}
    @parsed_error.relevant_info.each do |key,value|
      params["error_message[#{key}]"] = value
    end
    Net::HTTP::post_form(uri, params)
  end

  def response
    @env['exception_handler.layout'] = @controller.send(:_default_layout) || RailsExceptionHandler.configuration.fallback_layout
    @env['exception_handler.response_code'] = @parsed_error.routing_error? ? '404' : '500'
    ErrorResponseController.action(:index).call(@env)
  end
end
