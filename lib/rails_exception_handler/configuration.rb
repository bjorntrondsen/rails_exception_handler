class RailsExceptionHandler::Configuration
  attr_accessor :storage_strategies, :environments, :filters, :responses, :fallback_layout

  def initialize
    @environments = [:production]
    @storage_strategies = []
    @filters = []
    @responses = { '404' => '<h1>Page not found</h1><p>The page you were looking for could not be found.</p>',
                   '500' => '<h1>Internal server error</h1><p>The application has encountered an unexpected issue.</p>' }
    @fallback_layout = 'application'
  end

  def ignore_routing_errors?
    @ignore_routing_errors
  end

  def ignore_crawlers?
    @ignore_crawlers
  end
end
