if(RailsExceptionHandler.configuration.activate?)
  class ErrorResponseController < ApplicationController

    layout :exception_layout

    def index
      @exception_class      = env['exception_handler.exception_class']
      @exception_namespace  = @exception_class.underscore.gsub('/', '.')
      @response_mapping     = env['exception_handler.response_mapping']
      @status_code          = env['exception_handler.status_code']
      @rescue_response      = env['exception_handler.rescue_response']
      render RailsExceptionHandler.configuration.mapping_views ? @response_mapping : :index
    end

    def dummy_action
      render nothing: true
    end

    private

    def exception_layout
      env['exception_handler.layout']
    end

  end
end
