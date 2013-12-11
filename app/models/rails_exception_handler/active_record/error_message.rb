
class RailsExceptionHandler::ActiveRecord

  class ErrorMessage < defined?(ActiveRecord) ? ActiveRecord::Base : Object
    if defined?(ActiveRecord)
      establish_connection(:exception_database)
      self.table_name = :error_messages
    end
  end

end
