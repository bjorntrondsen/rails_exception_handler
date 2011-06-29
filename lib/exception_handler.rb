
require 'exception_handler/handler.rb'
require 'exception_handler/parser.rb'
require 'exception_handler/show_exception.rb'
require 'exception_handler/error_message.rb'
require 'exception_handler/error_response_controller.rb'

class ExceptionHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    Handler.new(env, e).handle_exception
  end
end

ActionController::Dispatcher.middleware.use ExceptionHandler
