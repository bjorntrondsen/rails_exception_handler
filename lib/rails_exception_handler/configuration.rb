class RailsExceptionHandler::Configuration
  attr_accessor :environments, :catch_routing_errors

  def initialize
    @environments = ['production']
    @catch_routing_errors = true
  end

  def catch_routing_errors?
    @catch_routing_errors
  end
end
