class RailsExceptionHandler::Configuration
  attr_accessor :storage_strategies, :environments, :filters, :responses, :fallback_layout, :store_user_info

  def initialize
    @environments = [:production]
    @storage_strategies = []
    @filters = []
    @store_user_info = false
    @fallback_layout = 'application'
    @responses = { '404' => '<h1>Page not found</h1><p>The page you were looking for could not be found.</p>',
                   '500' => '<h1>Internal server error</h1><p>The application has encountered an unexpected issue.</p>' }
  end
end
