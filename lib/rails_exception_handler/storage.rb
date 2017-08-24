class RailsExceptionHandler::Storage

  def self.active_record(info)
  
    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 0
      RailsExceptionHandler::ActiveRecord::ErrorMessage.create(info, :without_protection => true) if RailsExceptionHandler::ActiveRecord::ErrorMessage.respond_to?(:create)
    else
      RailsExceptionHandler::ActiveRecord::ErrorMessage.create(info) if RailsExceptionHandler::ActiveRecord::ErrorMessage.respond_to?(:create)
    end
	
	email = RailsExceptionHandler.configuration.email
	RailsExceptionHandler::Storage.notify(info,email) unless email.blank?
		
  end

  def self.mongoid(info)
  
    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 0
      RailsExceptionHandler::Mongoid::ErrorMessage.create(info, :without_protection => true) if RailsExceptionHandler::Mongoid::ErrorMessage.respond_to?(:create)
    else
      RailsExceptionHandler::Mongoid::ErrorMessage.create(info) if RailsExceptionHandler::Mongoid::ErrorMessage.respond_to?(:create)
    end
	
	email = RailsExceptionHandler.configuration.email
	RailsExceptionHandler::Storage.notify(info,email) unless email.blank?
  end

  # Notify application admin that an error occured
  def self.notify(info,email)
          ErrorMailer.send_error_mail_to_admin(info.to_json,email).deliver_later
  end
  
  def self.rails_log(info)
    message = ""
    info.each do |key,val|
      message += "#{key.to_s.upcase}: #{val.to_s}\n"
    end
    Rails.logger.fatal(message)
  end

  def self.remote_url(target, info)
    uri = URI.parse(target)
    params = flatten_hash({:error_message => info})
    Net::HTTP::post_form(uri, params)
  end

  private

  # Credit: Hash flattening technique borrowed from Peter Marklund: http://marklunds.com/articles/one/314
  def self.flatten_hash(hash, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += "[]" if v.is_a?(Array)
        flat_hash[key] = v
      end
    end
    flat_hash
  end

  def self.flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end
end
