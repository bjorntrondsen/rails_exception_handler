# Rails Exception Handler [![Build Status](http://travis-ci.org/Sharagoz/rails_execption_handler.png)](http://travis-ci.org/#!/Sharagoz/rails_exception_handler)
This is work in progress. A gem has not been released yet.

This is an exception handler for Rails 3 built as Rack middleware. It enables you to save the key information from the error message in a database somewhere and display a customized error message to the user within the applications layout file. You can hook this gem into all your rails apps and gather the exception reports in one place. If you make yourself a simple web front on top of that you have a user friendly way of keeping track of exceptions raised by your rails apps.

## Installation
Add this line to your Gemfile:

```
config.gem 'rails_exception_handler', '~> 1.0'
```

Create an initializer in **config/initializers** called **rails_exception_handler.rb** with this code:

```ruby
RailsExceptionHandler.configure do |config|
  # The configuration options are explained below
end
```


## Configuration
Here are the available config options. Storage strategy must be chosen, the rest are optional and can be left out.

```ruby
RailsExceptionHandler.configure do |config|
  config.storage_strategy = :active_record                      # Either :active_record or :remote_url
  config.environments = [:development, :test, :production]      # Defaults to [:production]
  config.catch_routing_errors = false                           # Defaults to true
  config.responses['404'] = "<h1>404</h1><p>Page not found</p>"
  config.responses['500'] = "<h1>500</h1><p>Internal server error</p>"
end
```


## Storage strategy - active record
This means that the error messages will be stored directly in a database somewhere. A new entry called **exception_database** is needed in **database.yml**:

```yml
# for mysql the entry would look something like this:
exception_database:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: your_database
  pool: 5
  username: user
  password: secret
  host: 127.0.0.1
```

You could of course store the error messages in the same database as the application uses, but one of the main purposes of this gem is to enable you to easily store error messages from many applications in the same database, so I recommend you set up a separate dedicated database for this.

The exception database needs a table which by default is called **error_messages** (can be overridden in the config). Here's a migration file that shows which fields are needed:

```ruby
class CreateErrorMessages < ActiveRecord::Migration
  def self.up
    create_table :error_messages do |t|
      t.text :class_name
      t.text :message
      t.text :trace
      t.text :params
      t.text :target_url
      t.text :referer_url
      t.text :user_agent
      t.string :user_info
      t.string :app_name

      t.timestamps
    end
  end

  def self.down
    drop_table :error_messages
  end
end
```


## Storage strategy - remote url
(not yet implemented)
