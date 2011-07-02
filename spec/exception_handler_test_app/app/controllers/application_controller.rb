class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    mock = Object.new
    def mock.login
      'superman'
    end
    return mock
  end

end
