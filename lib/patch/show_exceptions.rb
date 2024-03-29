# This patch enables the exception handler to catch routing errors
module ActionDispatch
  class ShowExceptions
    private
      def render_exception_with_template(env, exception)
        env = env.env if env.is_a?(ActionDispatch::Request) # Rails 5 passes in the whole request object
        if(RailsExceptionHandler.configuration.activate?)
          RailsExceptionHandler::Handler.new(env, exception).handle_exception
        else
          raise exception
        end
      end
      alias_method :render_exception, :render_exception_with_template
      alias_method :template, :render_exception
  end
end
