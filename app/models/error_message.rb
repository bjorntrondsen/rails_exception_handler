if(defined?(ActiveRecord) && RailsExceptionHandler.configuration.activate? && RailsExceptionHandler.configuration.active_record?)
  class ErrorMessage < ActiveRecord::Base
    establish_connection(:exception_database)
  end
end
