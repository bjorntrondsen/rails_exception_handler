# encoding: utf-8
require 'rubygems'
require 'rake'
require 'jeweler'

task :default => :test

desc 'Run tests'
task :test do
  files = ["spec/unit/handler_spec.rb",
           "spec/unit/parser_spec.rb",
           "spec/unit/configuration_spec.rb",
           "spec/integration/rails_exception_handler_spec.rb", 
           "spec/integration/configuration_spec.rb"
          ]
  system "bundle exec rspec spec"
end

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rails_exception_handler"
  gem.homepage = "http://github.com/Sharagoz/rails_exception_handler"
  gem.license = "MIT"
  gem.summary = %Q{Exception Handling for Rails 3}
  gem.description = %Q{}
  gem.email = "contact@sharagoz.com"
  gem.authors = ["Sharagoz"]
  gem.extra_rdoc_files = ['README.markdown']
  gem.require_paths = ["lib"]
  gem.files.exclude 'spec/**/*'

  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
