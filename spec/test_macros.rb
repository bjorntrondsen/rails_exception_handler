module TestMacros
  def app # Used by by Rack::Test to get the application object
    Rails.application.app
  end

  def create_env
    s = Rack::Test::Session.new(nil)
    env = s.send(:env_for,'/home/', {:params => {:foo => 'bar'}, 'HTTP_REFERER' => 'http://google.com/', 'HTTP_USER_AGENT' => "Mozilla/4.0 (compatible; MSIE 8.0)"})
  end

  def create_exception
    exception = nil
    begin
      nil.foo
    rescue Exception => e
      exception = e
    end
  end
end
