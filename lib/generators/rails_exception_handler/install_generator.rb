class RailsExceptionHandler
  class InstallGenerator < Rails::Generators::Base
    desc "Copy initialization file"
    source_root File.expand_path('../templates', __FILE__)
    class_option :template_engine

    def copy_initializer
      copy_file 'rails_exception_handler.rb', 'config/initializers/rails_exception_handler.rb'
    end
  end
end
