# Rails Exception Handler [![Build Status](http://travis-ci.org/Sharagoz/rails_execption_handler.png)](http://travis-ci.org/#!/Sharagoz/rails_exception_handler)
This is work in progress. A gem has not been released yet.

This is an exception handler for Rails 3 built as Rack middleware. It enables you to save the key information from the error message in a database somewhere and display a customized error message to the user within the applications layout file. You can hook this gem into all your rails apps and gather the exception reports in one place. If you make yourself a simple web front on top of that you have a user friendly way of keeping track of exceptions raised by your rails apps.

## Installation
Add this line to your Gemfile:

```
config.gem 'rails_exception_handler', '~> 1.0'
```

Create an initializer in **config/initializers** called **rails_exception_handler.rb** and uncomment the options where you want to something other than the default:

```ruby
RailsExceptionHandler.configure do |config|
  # config.storage_strategies = [:active_record]                            # Defaults to []
  # config.environments = [:development, :test, :production]                # Defaults to [:production]
  # config.ignore_routing_errors = true                                     # Defaults to false
  # config.user_agent_regxp = your_reg_xp                                   # Defaults to blank
  # config.responses['404'] = "<h1>404</h1><p>Page not found</p>"
  # config.responses['500'] = "<h1>500</h1><p>Internal server error</p>"
  # config.fallback_layout = 'home'                                         # Defaults to 'application'
end
```

## Configuration options

As far as the filters go, I recommend you start out by disabling all of them, and then add those you find necessary from personal experience.

### storage_strategies
An array of zero or more symbols that says which storage strategies you want to use. Each are explained in detail in separate sections below.

```ruby
config.storage_strategies = [:active_record, :remote_url, :rails_log]
```

Default value: []

### environments
An array of symbols that says which Rails environments you want the exception handler to run in.

```ruby
config.environments = [:production, :test, :development]
```

Default value: [:production]

### ignore_routing_errors

```ruby
config.ignore_routing_errors = true
```

Default value: false

When set to true it ignores these exceptions: ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound

### user_agent_regxp

```ruby
config.filters.user_agent_regxp = /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Yandex|Jyxobot|Huaweisymantecspider|ApptusBot|TurnitinBot|DotBot)\b/i

```

Default value: blank

Filters the user agent string against a regxp. In the example above you can see the string I'm personally using, which is based on crawlers that I have actually seen generate errors in my apps within the last few years. There are huge lists out on the web with the user agent strings of thousands of known bots, but I have not found it necessary to make use of them.


## Storage strategy - active record
This means that the error messages will be stored directly in a database somewhere. A new entry called **exception_database** is needed in **database.yml**:

```
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

## Storage strategy - rails_log
An error will be logged in the standard rails log. The log i located in the RAILS_ROOT/log directory and is named after the Rails environment.
Example:

```
TARGET:     http://localhost:3000/home/view_error
REFERER:    /
PARAMS:     {"controller"=>"home", "action"=>"view_error"}
USER_AGENT: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30
USER_INFO:  superman
ActionView::Template::Error (ActionView::Template::Error):
activesupport (3.0.7) lib/active_support/whiny_nil.rb:48:in `method_missing'
actionpack (3.0.7) lib/action_view/template.rb:135:in `block in render'
activesupport (3.0.7) lib/active_support/notifications.rb:54:in `instrument'
(the rest of the stack trace has been omitted from the example)
```


## Storage strategy - remote url
(not yet implemented)
