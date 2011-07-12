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
  
  def log_error(info)
    message = "#{info[:class_name]} (#{info[:message]}):\n  "
    message += Rails.backtrace_cleaner.clean(info[:trace].split("\n"), :noise).join("\n")
    Rails.logger.fatal(message)
  end
  
  private

  def store_error
    ErrorMessage.create(@parsed_error.relevant_info) if(RailsExceptionHandler.configuration.storage_strategies.include?(:active_record))
    log_error(@parsed_error.relevant_info)
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
