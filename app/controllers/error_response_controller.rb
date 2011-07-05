class ErrorResponseController < ActionController::Base
  def index
    render(:text => RailsExceptionHandler.configuration.responses[@_env['exception_handler.response_code']],
           :layout => @_env['exception_handler.layout'])
  end
end
