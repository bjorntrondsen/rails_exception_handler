class RailsExceptionHandler::Parser
  attr_accessor :external_info, :internal_info

  def initialize(env, request, exception, controller)
    @env = env
    @request  = request
    @exception = exception
    @controller = controller
    @external_info = {}
    @internal_info = {}
    parse
  end

  def parse
    @internal_info[:error_class] =    @exception.class.to_s
    @internal_info[:target_url] =     @request.url
    @internal_info[:referer_url] =    @request.referer
    @internal_info[:user_agent] =     @request.user_agent

    config = RailsExceptionHandler.configuration
    config.request_info_block.call(@external_info, @request) if(config.request_info_block)
    config.exception_info_block.call(@external_info, @exception) if(config.exception_info_block)
    config.env_info_block.call(@external_info, @env) if(config.env_info_block)
    config.global_info_block.call(@external_info) if(config.global_info_block)
    @external_info[:user_info] = user_info if(user_info)
  end

  def ignore?
    filters = RailsExceptionHandler.configuration.filters
    filters.each do |filter|
      if(filter.class == Symbol)
        result = send("filter_#{filter}")
      elsif(filter.class == Hash)
        result = send("filter_#{filter.keys[0]}", filter.values[0])
      else
        raise "RailsExceptionHandler: Unknown filter #{filter.inspect}"
      end
      return true if(result)
    end
    return false
  end

  def routing_error?
    routing_errors = ['ActionController::RoutingError', 'AbstractController::ActionNotFound', 'ActiveRecord::RecordNotFound']
    routing_errors.include?(@exception.class.to_s)
  end

  def anon_user?
    [nil,'Anonymous'].include?(user_info)
  end

  private

  def blank_referer?
    @internal_info[:referer_url] == "/" || @internal_info[:referer_url].blank?
  end

  def user_info
    config = RailsExceptionHandler.configuration.store_user_info
    return nil unless(config)
    user_object = @controller.send(config[:method])
    user_object ? user_object.send(config[:field]) : 'Anonymous'
  end

  def filter_all_404s
    routing_error?
  end

  def filter_no_referer_404s
    routing_error? && blank_referer?
  end

  def filter_anon_404s
    routing_error? && anon_user?
  end

  def filter_user_agent_regxp(regxp)
    result = @internal_info[:user_agent].match(regxp)
    result != nil
  end

  def filter_target_url_regxp(regxp)
    result = @internal_info[:target_url].match(regxp)
    result != nil
  end
end
