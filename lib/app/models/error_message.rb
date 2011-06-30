class ErrorMessage < ActiveRecord::Base
  establish_connection(:exception_database)
end
