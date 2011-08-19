class ErrorMessage < ActiveRecord::Base
  establish_connection(:exception_database) if RailsExceptionHandler.configuration.active_record?
end
