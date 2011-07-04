class RailsExceptionHandler::Configuration
  attr_accessor :environments

  def initialize
    @environments = ['production']
  end
end
