class RailsExceptionHandler::Storage
  def self.store_in_active_record(info)
    ErrorMessage.create(info)
  end

  def self.store_in_rails_log(info)
    message  = "TARGET:     #{info[:target_url]}\n"
    message += "REFERER:    #{info[:referer_url]}\n"
    message += "PARAMS:     #{info[:params]}\n"
    message += "USER_AGENT: #{info[:user_agent]}\n"
    message += "USER_INFO:  #{info[:user_info]}\n"
    message += "#{info[:class_name]} (#{info[:message]}):\n"
    message += Rails.backtrace_cleaner.clean(info[:trace].split("\n"), :noise).join("\n")
    Rails.logger.fatal(message)
  end

  def self.store_in_remote_url(target, info)
    uri = URI.parse(target)
    params = {}
    info.each do |key,value|
      params["error_message[#{key}]"] = value
    end
    Net::HTTP::post_form(uri, params)
  end
end
