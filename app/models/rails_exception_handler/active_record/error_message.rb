
class RailsExceptionHandler::ActiveRecord

  class ErrorMessage < defined?(ActiveRecord) ? ActiveRecord::Base : Object
    if(defined?(ActiveRecord) && RailsExceptionHandler.configuration.activate? && RailsExceptionHandler.configuration.active_record?)
      establish_connection(:exception_database)
      self.table_name = :error_messages
    end
  end

end
