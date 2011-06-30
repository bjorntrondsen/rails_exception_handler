require 'exception_handler'

%w{ models controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'lib/app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path) if(Rails.env == 'production')
end

Rails::Application.middleware.use ExceptionHandler# if Rails.env == 'production'
