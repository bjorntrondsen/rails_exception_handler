begin
  require File.join(File.dirname(__FILE__), 'lib', 'declarative_authorization')
rescue LoadError
  require 'declarative_authorization'
end
