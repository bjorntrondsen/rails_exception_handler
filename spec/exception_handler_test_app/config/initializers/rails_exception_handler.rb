
RailsExceptionHandler.configure do |config|
  config.storage_strategy = :active_record
  config.environments = [:test]
end
