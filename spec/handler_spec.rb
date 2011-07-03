require File.expand_path(File.dirname(__FILE__)) + '/spec_helper.rb'

describe RailsExceptionHandler::Handler do
  describe ".handle_exception" do
    it "should store an error message in the database"

    it "should log an error to the log file"
  end

  describe ".log_error" do
    it "should log an error in the correct format"
  end

  describe '.response' do
    it "should call err404 on routing errors"

    it "should call err500 on all other errors"

    it "should save the layout"

    it "should use the fallback layout when no layout is defined"
  end
end
