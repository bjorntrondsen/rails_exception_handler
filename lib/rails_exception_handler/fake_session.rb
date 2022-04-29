class RailsExceptionHandler::FakeSession < Hash
  def enabled?
    false
  end

  def options
    {}
  end
end
