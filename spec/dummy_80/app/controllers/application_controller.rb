class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

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
