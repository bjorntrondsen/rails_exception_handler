class RailsExceptionHandler

  def self.catch(&block)
    begin
      block.call
    rescue Exception => exception
      if(configuration.activate?)
        notify(exception)
      else
        raise exception
      end
    end
  end

  def self.notify(exception)
    exception_handler = Handler.new({ 'REQUEST_METHOD' => "GET", "rack.input" => "" }, exception)
    exception_handler.handle_exception
  end
end
