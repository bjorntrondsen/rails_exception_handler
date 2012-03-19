class RailsExceptionHandler::Handler
  def initialize(env, exception)
    @exception = exception
    @env = env
    @request = ActionDispatch::Request.new(@env)
    @parsed_error = nil
    if(@env['action_controller.instance'])
      @controller = @env['action_controller.instance']
    else
      # A routing error has occurred and no controller instance exists. Here I am firing off a 
      # request to a dummy action that goes through the whole action dispatch stack, which will
      # hopefully make sure that any authentication mechanism are properly initialized so that 
      # we may get the current_user object later.
      @controller = ErrorResponseController.new
      @controller.request = @request
      @controller.response = ActionDispatch::Response.new
      @controller.process(:dummy_action)
    end
  end

  def handle_exception
    @parsed_error = RailsExceptionHandler::Parser.new(@env, @request, @exception, @controller)
    store_error unless(@parsed_error.ignore?)
    return response
  end
  
  private

  def store_error
    RailsExceptionHandler.configuration.storage_strategies.each do |strategy|
      if(strategy.class == Symbol)
        RailsExceptionHandler::Storage.send("store_in_#{strategy}",@parsed_error.external_info)
      elsif(strategy.class == Hash && strategy[:remote_url])
        RailsExceptionHandler::Storage.store_in_remote_url(strategy[:remote_url][:target],@parsed_error.external_info)
      else
        raise "RailsExceptionHandler: Unknown storage strategy #{strategy.inspect}"
      end
    end
  end

  def response
    @env['exception_handler.layout'] = response_layout
    @env['exception_handler.response'] = response_text
    response = ErrorResponseController.action(:index).call(@env)
    if @parsed_error.routing_error? 
      response[0] = 404
      file = "#{Rails.root}/public/404.html"
      response[2].body = File.read(file) if File.exists?(file)
    else
      response[0] = 500
      file = "#{Rails.root}/public/500.html"
      response[2].body = File.read(file) if File.exists?(file)
    end
    return response
  end

  def response_layout
    if(@request.xhr?)
      false
    else
      default_layout = @controller.send(:_default_layout)
      if(default_layout.class.to_s == "ActionView::Template")
        layout = default_layout.virtual_path
      else
        layout = default_layout
      end
      layout || RailsExceptionHandler.configuration.fallback_layout
    end
  end

  def response_text
    config = RailsExceptionHandler.configuration
    klass = @parsed_error.internal_info[:error_class]
    key = config.response_mapping[klass] || :default
    return config.responses[key]
  end
end

