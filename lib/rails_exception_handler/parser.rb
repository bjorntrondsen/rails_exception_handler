class RailsExceptionHandler::Parser
  def initialize(exception, request, controller)
    @exception = exception
    @request  = request
    @controller = controller
  end

  def relevant_info
    info = {}
    info[:app_name] =     Rails.application.class.parent_name
    info[:class_name] =   @exception.class.to_s
    info[:message] =      @exception.to_s
    info[:trace] =        @exception.backtrace.join("\n")
    info[:target_url] =   @request.url
    info[:referer_url] =  @request.referer
    info[:params] =       @request.params.inspect
    info[:user_agent] =   @request.user_agent
    info[:user_info] =    user_info
    info[:created_at] =   Time.now
    return info
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
    routing_errors = [ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound]
    routing_errors.include?(@exception.class)
  end

  private

  def blank_referer?
    relevant_info[:referer_url] == "/" || relevant_info[:referer_url].blank?
  end

  def user_info
    config = RailsExceptionHandler.configuration.store_user_info
    return nil unless(config)
    begin
      user_object = @controller.send(config[:method])
    rescue
      user_object = nil
    end
    user_object ? user_object.send(config[:field]) : 'Anonymous'
  end

  def filter_all_404s
    routing_error?
  end

  def filter_no_referer_404s
    routing_error? && blank_referer?
  end

  def filter_user_agent_regxp(regxp)
    result = relevant_info[:user_agent].match(regxp)
    result != nil
  end

  def filter_target_url_regxp(regxp)
    result = relevant_info[:target_url].match(regxp)
    result != nil
  end
end
