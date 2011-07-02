class ExceptionHandler::Parser
  def initialize(exception, request, controller)
    @exception = exception
    @request  = request
    @controller = controller
  end

  def relevant_info
    info = {}
    info[:app_name] = Rails.application.class.parent_name
    info[:class_name] = @exception.class.to_s
    info[:message] = @exception.to_s
    info[:trace] = @exception.backtrace.join("\n")
    info[:target_url] = @request.url
    info[:referer_url] = @request.referer
    info[:params] = @request.params.inspect
    info[:user_agent] = @request.user_agent
    info[:user_info] = user_info
    return info
  end

  def ignore?
    #Ignore routing errors in requests without a referer as they are going to be bots in 99.99235% of the cases
    if(routing_error? && @request.referer.blank?)
      return true
    end
    #Ignore requests with user_agents matching this regxp as they can be assumed to have been made by bots
    if(@request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Yandex|Jyxobot|Huaweisymantecspider|ApptusBot|TurnitinBot)\b/i)
      return true
    end
    return false
  end

  def routing_error?
    routing_errors = [ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound]
    routing_errors.include?(@exception.class)
  end

  def user_info
    if(@controller.respond_to?(:current_user))
      current_user = @controller.current_user
      [:login, :username, :email].each do |field|
        return current_user.send(field) if(current_user.respond_to?(field))
      end
    end
    return nil
  end
end
