class RailsExceptionHandler::Handler
  def initialize(env, exception)
    @exception = exception
    @env = env
    @parsed_error = nil
    @controller = @env['action_controller.instance']
  end

  def handle_exception
    request = ActionDispatch::Request.new(@env)
    @parsed_error = RailsExceptionHandler::Parser.new(@exception, request, @controller)
    store_error unless(@parsed_error.ignore?)
    return response
  end
  
  private

  def store_error
    strategies = RailsExceptionHandler.configuration.storage_strategies
    if(strategies.include?(:active_record))
      ErrorMessage.create(@parsed_error.relevant_info)
    end
    if(strategies.include?(:rails_log))
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
  end

  def response
    begin
      @env['exception_handler.layout'] = @controller.send(:_default_layout) # Store the layout of the request that failed
    rescue
      @env['exception_handler.layout'] = RailsExceptionHandler.configuration.fallback_layout # Fall back on routing errors that doesnt have _default_layout set
    end
    @env['exception_handler.response_code'] = @parsed_error.routing_error? ? '404' : '500'
    ErrorResponseController.action(:index).call(@env)
  end
end
