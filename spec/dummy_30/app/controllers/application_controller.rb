class ApplicationController < ActionController::Base
  protect_from_forgery

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
