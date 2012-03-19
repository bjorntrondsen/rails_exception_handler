class RailsExceptionHandler::Storage
  def self.store_in_active_record(info)
    ErrorMessage.create(info)
  end

  def self.store_in_rails_log(info)
    message = ""
    info.each do |key,val|
      message += "#{key.upcase}: #{val.to_s}\n"
    end
    Rails.logger.fatal(message)
  end

  def self.store_in_remote_url(target, info)
    uri = URI.parse(target)
    params = {:error_message => info}
    Net::HTTP::post_form(uri, params)
  end
end
