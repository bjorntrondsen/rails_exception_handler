# encoding: utf-8
require 'rubygems'
require 'rake'

task :default => :test

desc 'Run tests'
task :test do
  system "bundle exec rspec spec/integration_spec.rb spec/handler_spec.rb spec/parser_spec.rb"
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rails_exception_handler"
  gem.homepage = "http://github.com/Sharagoz/rails_exception_handler"
  gem.license = "MIT"
  gem.summary = %Q{Exception Handling for Rails 3}
  gem.description = %Q{}
  gem.email = "contact@sharagoz.com"
  gem.authors = ["Sharagoz"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
