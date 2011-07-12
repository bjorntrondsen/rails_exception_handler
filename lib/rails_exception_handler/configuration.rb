class RailsExceptionHandler::Configuration
  attr_accessor :storage_strategies, :environments, :ignore_routing_errors, :ignore_crawlers, :responses, :fallback_layout

  def initialize
    @environments = [:production]
    @storage_strategies = []
    @ignore_routing_errors = false
    @ignore_crawlers = false
    @responses = { '404' => '<h1>Page not found</h1><p>The page you were looking for could not be found.</p>',
                   '500' => '<h1>An error has occurred</h1><p>The error has been logged and will be reviewed by a system administrator.</p>' }
    @fallback_layout = 'application'
  end

  def ignore_routing_errors?
    @ignore_routing_errors
  end

  def ignore_crawlers?
    @ignore_crawlers
  end
end
