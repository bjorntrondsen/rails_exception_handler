class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    mock = Object.new
    def mock.login
      'matz'
    end
    return mock
  end

  def nil_user
    return nil
  end

end
