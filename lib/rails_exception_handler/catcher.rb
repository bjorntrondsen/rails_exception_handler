class RailsExceptionHandler

  def self.catch(&block)
    begin
      block.call
    rescue Exception => exception
      if(configuration.activate?)
        exception_handler = Handler.new({'REQUEST_METHOD' => "GET", "rack.input" => ""}, exception)
        exception_handler.handle_exception
      else
        raise exception
      end
    end
  end

end
