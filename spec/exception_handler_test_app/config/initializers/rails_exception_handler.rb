
RailsExceptionHandler.configure do |config|
  config.environments = ['test']
  # config.catch_routing_errors = false
  config.responses['404'] = "<h1>404</h1><p>Page not found</p>"
  config.responses['500'] = "<h1>500</h1><p>Internal server error</p>"
end
