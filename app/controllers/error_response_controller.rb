class ErrorResponseController < ActionController::Base
  def err500
    render(:layout => @_env['layout_for_exception_response'])
  end

  def err404
    render(:layout => @_env['layout_for_exception_response'])
  end
end
