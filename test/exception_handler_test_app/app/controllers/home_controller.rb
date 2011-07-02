class HomeController < ApplicationController
  def action_with_error
    raise "error"
  end
end
