class ErrorResponseController < ApplicationController
  def index
    render(:text => @_env['exception_handler.response'], :layout => @_env['exception_handler.layout'])
  end

  def dummy_action
    render :nothing => true
  end
end
