# This patch enables the exception handler to catch routing errors
module ActionDispatch
  class ShowExceptions
    private
      def render_exception_with_template(env, exception)
        ExceptionHandler::Handler.new(env, exception).handle_exception
      end
      alias_method_chain :render_exception, :template
  end
end
