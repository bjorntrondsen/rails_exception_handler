class RailsExceptionHandler::Handler
  def initialize(env, exception)
    @exception = exception
    @env = env
    @parsed_error = nil
  end

  def handle_exception
    controller = @env['action_controller.instance']
    request = ActionDispatch::Request.new(@env)
    @parsed_error = RailsExceptionHandler::Parser.new(@exception, request, controller)
    ErrorMessage.create(@parsed_error.relevant_info) unless(@parsed_error.ignore?)
    log_error(@parsed_error.relevant_info)
    return response
  end
  
  def log_error(info)
    message = "#{info[:class_name]} (#{info[:message]}):\n  "
    message += Rails.backtrace_cleaner.clean(info[:trace].split("\n")).join("\n")
    Rails.logger.fatal(message)
  end
  
  private

  def response
    begin
      @env['layout_for_exception_response'] = @env['action_controller.instance'].send(:_default_layout) # Store the layout
    rescue
      @env['layout_for_exception_response'] = 'application'
    end
    if(@parsed_error.routing_error?)
      ErrorResponseController.action(:err404).call(@env)
    else
      ErrorResponseController.action(:err500).call(@env)
    end
  end
end
