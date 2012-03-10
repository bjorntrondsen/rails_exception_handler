class RailsExceptionHandler::Configuration
  attr_accessor :storage_strategies, :environments, :filters, :responses, :response_mapping, :fallback_layout, :store_user_info

  def initialize
    @environments = [:production]
    @storage_strategies = []
    @filters = []
    @store_user_info = false
    @fallback_layout = 'application'
    @response_mapping = {}
    @responses = {}
  end

  def active_record?
    @storage_strategies.include?(:active_record)
  end

  def activate?
    environments.include?(Rails.env.to_sym)
  end
end
