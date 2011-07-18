begin
  require File.join(File.dirname(__FILE__), 'lib', 'rails_exception_handler')
rescue LoadError
  require 'rails_exception_handler'
end
