class RailsExceptionHandler::ActiveRecord

  class ErrorMessage < defined?(ActiveRecord) ? ActiveRecord::Base : Object
    if (defined?(ActiveRecord) && RailsExceptionHandler.configuration.activate? && RailsExceptionHandler.configuration.active_record?)
      establish_connection(RailsExceptionHandler.configuration.active_record_store_in[:database].to_sym)
      self.table_name = RailsExceptionHandler.configuration.active_record_store_in[:record_table]
    end
  end

end
