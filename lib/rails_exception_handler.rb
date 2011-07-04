class RailsExceptionHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    Handler.new(env, e).handle_exception
  end

  def self.configure
    #if Rails.env == 'production'
    require File.expand_path(File.dirname(__FILE__)) + '/patch/show_exceptions.rb'
    %w{ models controllers }.each do |dir|
      path = File.join(File.dirname(__FILE__), 'app', dir)
      $LOAD_PATH << path
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    end
    Rails.configuration.middleware.use RailsExceptionHandler
    Rails.configuration.action_dispatch.show_exceptions = true
    #end
  end
end
