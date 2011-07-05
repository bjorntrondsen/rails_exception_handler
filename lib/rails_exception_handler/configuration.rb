class RailsExceptionHandler::Configuration
  attr_accessor :storage_strategy, :environments, :catch_routing_errors, :responses

  def initialize
    @environments = [:production]
    @catch_routing_errors = true
    @responses = { '404' => '<h1>Page not found</h1><p>The page you were looking for could not be found.</p>',
                   '500' => '<h1>An error has occurred</h1><p>The error has been logged and will be reviewed by a system administrator.</p>' }
  end

  def catch_routing_errors?
    @catch_routing_errors
  end
end
