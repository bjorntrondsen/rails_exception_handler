require 'spec_helper'

describe RailsExceptionHandler do
  let(:message) { 'Oops, I did it again' }

  example 'catching outside of rack' do
    described_class.notify(Exception.new(message))
    RailsExceptionHandler::ActiveRecord::ErrorMessage.count.should == 1
    RailsExceptionHandler::ActiveRecord::ErrorMessage.first.message.should eq(message)
  end
end
