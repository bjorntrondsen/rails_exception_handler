require 'spec_helper'

describe RailsExceptionHandler do
  example 'catching outside of rack' do
    RailsExceptionHandler.catch { raise "I failed misserably" }
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.message.should eq("I failed misserably")
  end
end
