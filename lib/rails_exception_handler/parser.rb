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
        result = send("filter_#{filter.flatten[0]}", filter.flatten[1])
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
    if(@controller.respond_to?(:current_user))
      current_user = @controller.current_user
      [:login, :username, :user_name, :email].each do |field|
        return current_user.send(field) if(current_user.respond_to?(field))
      end
    end
    return nil
  end

  def filter_all_routing_errors
    routing_error?
  end

  def filter_routing_errors_without_referer
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
