class RailsExceptionHandler < Rails::Engine

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    Handler.new(env, e).handle_exception
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
    return unless configuration.environments.include?(Rails.env.to_sym)

    Rails.configuration.middleware.use(RailsExceptionHandler)

    Rails.configuration.action_dispatch.show_exceptions = true
    require File.expand_path(File.dirname(__FILE__)) + '/patch/show_exceptions.rb'
  end
end

require 'rails_exception_handler/configuration.rb'
require 'rails_exception_handler/handler.rb'
require 'rails_exception_handler/parser.rb'
require 'net/http'
