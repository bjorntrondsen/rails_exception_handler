if(RailsExceptionHandler.configuration.activate?)
  class ErrorResponseController < ApplicationController
    def index
      if Rails::VERSION::MAJOR > 4
        render(:html => request.env['exception_handler.response'].html_safe, :layout => request.env['exception_handler.layout'])
      else
        render(:text => @_env['exception_handler.response'], :layout => @_env['exception_handler.layout'])
      end
    end

    def dummy_action
      if Rails::VERSION::MAJOR > 4
        render :body => nil
      else
        render :nothing => true
      end
    end
  end
end
