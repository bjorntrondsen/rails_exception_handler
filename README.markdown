# Rails Exception Handler [![Build Status](http://travis-ci.org/Sharagoz/rails_execption_handler.png)](http://travis-ci.org/#!/Sharagoz/rails_exception_handler)
This is work in progress. A gem has not been released yet.

This is an exception handler for Rails 3 built as Rack middleware. It enables you to save the key information from the error message in a database somewhere and display a customized error message to the user within the applications layout file. You can hook this gem into all your rails apps and gather the exception reports in one place. If you make yourself a simple web front on top of that you have a user friendly way of keeping track of exceptions raised by your rails apps.

## Installation
Add this line to your Gemfile:

```
config.gem 'rails_exception_handler', '~> 1.0'
```

Create an initializer in **config/initializers** called **rails_exception_handler.rb** and uncomment the options where you want something other than the default:

```ruby
RailsExceptionHandler.configure do |config|
  # config.environments = [:development, :test, :production]                # Defaults to [:production]
  # config.storage_strategies = [:active_record, :rails_log, :remote_url => {:target => 'http://example.com'}] # Defaults to []
  # config.fallback_layout = 'home'                                         # Defaults to 'application'
  # config.responses['404'] = "<h1>404</h1><p>Page not found</p>"
  # config.responses['500'] = "<h1>500</h1><p>Internal server error</p>"
  # config.filters = [                                                      # No filters are  enabled by default
  #   :all_routing_errors,
  #   :routing_errors_without_referer,
  #   {:user_agent_regxp => /\b(ApptusBot|TurnitinBot|DotBot|SiteBot)\b/i},
  #   {:target_url_regxp => /\b(myphpadmin)\b/i}
  #]
end
```

## Configuration options

As far as the filters go, I recommend you start out by disabling all of them, and then add those you find necessary from personal experience.

### environments
An array of symbols that says which Rails environments you want the exception handler to run in.

```ruby
config.environments = [:production, :test, :development]
```

Default value: [:production]

### storage_strategies
An array of zero or more symbols that says which storage strategies you want to use. Each are explained in detail in separate sections below.

```ruby
config.storage_strategies = [:active_record, :rails_log, :remote_url => {:target => 'http://example.com'}]
```

Default value: []
More than one storage strategy can be chosen.


### fallback_layout

```ruby
config.fallback_layout = 'home'
```

Default value: 'application'

The exception handler will always use the layout file of the controller action that was accessed when the error occured. However, when routing errors occures there are no controller action to get this layout from, so it falls back to the default 'application' layout that most apps have. If your application does not have a layout file called 'application', you need to override this, otherwise an error is raised.

### filters

All filters are disabled by default. I recommend you deploy your application this way, and then add filters as they become necessary.
The only reason I've ever wanted filtering have been due to what seem like poorly programmed web crawlers and black bots probing for security holes.
Every once in a while I'll get dozens of errors within a few minutes caused by a bot looking for things like Joomla/Wordpress libraries with known security holes, or a web crawler that follows the target of forms.


**:all_routing_errors**
Consider this a last resort. You will miss all "real" routing errors when this is turned on, like broken redirections.
When turned on the following exceptions will no longer be stored: ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound

**:routing_errors_without_referer**
This is very effective against bots. 99.9% of the time a routing error with no referer will be caused by a bot, and then once in a while it will be caused by a real user that happened to generate an error on the first page he opened.
**:user_agent_regxp**
The good guys always adds something to the user agent string that lets you identify them. You can use this to filter out the errors they genereate, and be pretty sure you are not going to get any false positives.
The string I use looks something like this:

```ruby
:user_agent_regxp => /\b(ZyBorg|Yandex|Jyxobot|Huaweisymantecspider|ApptusBot|TurnitinBot|DotBot)\b/i
```

If you (like me) dont know regular expressions by heart, then http://www.rubular.com/ is great tool.

**:target_url_regxp**
Sometimes the bad guys adds a common user agent string and a referer to their requests, which makes it hard to filter them without filtering all routing errors. I guess they do this to make it look less suspicious.
What you can often do is to filter on what they target, which is often some well known library like phpMyAdmin.

```ruby
:target_url_regxp => /\b(phpMyAdmin|joomla|wordpress)\b/i
```

## Storage strategy - active record
```ruby
config.storage_strategies = [:active_record]
```
This means that the error messages will be stored directly in a database somewhere, which is pretty much the whole reason why I created this gem in the first place. A new entry called **exception_database** is needed in **database.yml**:

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

The exception database needs a table called **error_messages**. Here's a migration file that shows which fields are needed:

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

## Storage strategy - rails log
```ruby
config.storage_strategies = [:rails_log]
```
An error will be logged in the standard rails log. The log i located in the RAILS_ROOT/log directory and is named after the Rails environment.
Example:

```
TARGET:     http://localhost:3000/home
REFERER:    /
PARAMS:     {"controller"=>"home", "action"=>"index"}
USER_AGENT: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30
USER_INFO:  superman
ActionView::Template::Error (ActionView::Template::Error):
activesupport (3.0.7) lib/active_support/whiny_nil.rb:48:in `method_missing'
actionpack (3.0.7) lib/action_view/template.rb:135:in `block in render'
activesupport (3.0.7) lib/active_support/notifications.rb:54:in `instrument'
(the rest of the stack trace has been omitted from the example)
```


## Storage strategy - remote url
```ruby
config.storage_strategies = [:remote_url => {:target => 'http://example.com/error_messages'}]
```
This option is meant for those who want to store the exception in a database table, but does not have direct access to the database itself, making active_record store unsuitable. You need a web app on a server that has access to the database. An HTTP POST request will be sent to the specified URL with the error message as data.
