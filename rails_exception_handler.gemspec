# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: rails_exception_handler 2.4.8 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_exception_handler".freeze
  s.version = "2.4.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["btrondsen".freeze]
  s.date = "2023-10-08"
  s.description = "".freeze
  s.email = "".freeze
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "HISTORY",
    "LICENCE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "app/controllers/error_response_controller.rb",
    "app/mailers/rails_exception_handler/error_mailer.rb",
    "app/models/rails_exception_handler/active_record/error_message.rb",
    "app/models/rails_exception_handler/mongoid/error_message.rb",
    "app/views/rails_exception_handler/error_mailer/send_error_mail_to_admin.html.erb",
    "app/views/rails_exception_handler/error_mailer/send_error_mail_to_admin.text.erb",
    "lib/generators/rails_exception_handler/install_generator.rb",
    "lib/generators/rails_exception_handler/templates/rails_exception_handler.rb",
    "lib/patch/show_exceptions.rb",
    "lib/rails_exception_handler.rb",
    "lib/rails_exception_handler/catcher.rb",
    "lib/rails_exception_handler/configuration.rb",
    "lib/rails_exception_handler/engine.rb",
    "lib/rails_exception_handler/fake_session.rb",
    "lib/rails_exception_handler/handler.rb",
    "lib/rails_exception_handler/parser.rb",
    "lib/rails_exception_handler/storage.rb",
    "rails_exception_handler.gemspec",
    "spec/dummy_30/.gitignore",
    "spec/dummy_30/lib/tasks/.gitkeep",
    "spec/dummy_30/public/.gitkeep",
    "spec/dummy_32/.gitignore",
    "spec/dummy_32/app/mailers/.gitkeep",
    "spec/dummy_32/app/models/.gitkeep",
    "spec/dummy_32/log/.gitkeep",
    "spec/dummy_32/public/.gitkeep",
    "spec/dummy_40/.gitignore",
    "spec/dummy_40/app/assets/images/.keep",
    "spec/dummy_40/app/mailers/.keep",
    "spec/dummy_40/app/models/.keep",
    "spec/dummy_40/lib/assets/.keep",
    "spec/dummy_40/lib/tasks/.keep",
    "spec/dummy_40/log/.keep",
    "spec/dummy_40/public/.gitkeep",
    "spec/dummy_42/.gitignore",
    "spec/dummy_42/app/assets/images/.keep",
    "spec/dummy_42/app/mailers/.keep",
    "spec/dummy_42/app/models/.keep",
    "spec/dummy_42/lib/assets/.keep",
    "spec/dummy_42/lib/tasks/.keep",
    "spec/dummy_42/log/.keep",
    "spec/dummy_42/public/.gitkeep",
    "spec/dummy_51/.gitignore",
    "spec/dummy_51/.ruby-version",
    "spec/dummy_51/app/assets/images/.keep",
    "spec/dummy_51/app/assets/javascripts/channels/.keep",
    "spec/dummy_51/app/controllers/concerns/.keep",
    "spec/dummy_51/app/models/concerns/.keep",
    "spec/dummy_51/lib/assets/.keep",
    "spec/dummy_51/lib/tasks/.keep",
    "spec/dummy_51/log/.keep",
    "spec/dummy_51/tmp/.keep",
    "spec/dummy_60/.gitignore",
    "spec/dummy_60/.ruby-version",
    "spec/dummy_60/app/assets/images/.keep",
    "spec/dummy_60/app/controllers/concerns/.keep",
    "spec/dummy_60/app/models/concerns/.keep",
    "spec/dummy_60/lib/assets/.keep",
    "spec/dummy_60/lib/tasks/.keep",
    "spec/dummy_60/log/.keep",
    "spec/dummy_60/tmp/.keep",
    "spec/dummy_70/.gitattributes",
    "spec/dummy_70/.gitignore",
    "spec/dummy_70/.ruby-version",
    "spec/dummy_70/app/assets/images/.keep",
    "spec/dummy_70/app/controllers/concerns/.keep",
    "spec/dummy_70/app/models/concerns/.keep",
    "spec/dummy_70/lib/assets/.keep",
    "spec/dummy_70/lib/tasks/.keep",
    "spec/dummy_70/log/.keep",
    "spec/dummy_70/tmp/.keep",
    "spec/dummy_70/tmp/pids/.keep",
    "spec/dummy_70/tmp/storage/.keep",
    "spec/dummy_71/.dockerignore",
    "spec/dummy_71/app/assets/images/.keep",
    "spec/dummy_71/app/controllers/concerns/.keep",
    "spec/dummy_71/app/models/concerns/.keep",
    "spec/dummy_71/lib/assets/.keep",
    "spec/dummy_71/lib/tasks/.keep",
    "spec/dummy_71/log/.keep",
    "spec/dummy_71/tmp/.keep",
    "spec/dummy_71/tmp/pids/.keep",
    "spec/dummy_71/tmp/storage/.keep"
  ]
  s.homepage = "https://github.com/bjorntrondsen/rails_exception_handler".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Highly customizable exception handling for Ruby on Rails".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<rails>.freeze, ["= 7.1.0"])
  s.add_development_dependency(%q<sprockets-rails>.freeze, [">= 0"])
  s.add_development_dependency(%q<rack-test>.freeze, ["= 1.1.0"])
  s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.4"])
  s.add_development_dependency(%q<juwelier>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec-rails>.freeze, ["= 4.1.2"])
  s.add_development_dependency(%q<rails_exception_handler>.freeze, [">= 0"])
end

