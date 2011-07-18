class ErrorResponseController < ApplicationController
  def index
    render(:text => @_env['exception_handler.response'], :layout => @_env['exception_handler.layout'])
  end
end
