# Rails Exception Handler [![Build Status](http://travis-ci.org/Sharagoz/rails_exception_handler.png)](http://travis-ci.org/#!/Sharagoz/rails_exception_handler)

Upgrading from version 1? [See wiki](https://github.com/Sharagoz/rails_exception_handler/wiki/Version-2.0-upgrade-instructions)

This is a flexible exception handler for Rails 3 intended for those who wish to create their own error tracking service. It is aimed at experienced Rails developers who are administrating more than just a couple of rails applications. Dont be intimidated if you're new to Rails though, it's not that hard to set up.

The exception handler enables you to save the key information from the error message in a database somewhere, via ActiveRecord or HTTP POST, and display a customized error message to the user within the applications layout file. You can hook this exception handler into all your rails apps and gather the exception reports in one place. The exception handler just contains the back end, you will have to create your own front end to view and manage the error reports. A Rails Engine admin interface, [rails_exception_handler_admin](https://github.com/mgwidmann/rails_exception_handler_admin), is a simple drop in interface or to use as an example for building your own.

Does your app have an authorization mechanism? [See wiki](https://github.com/Sharagoz/rails_exception_handler/wiki/Interaction-with-authorization-mechanisms)

Do you need to catch ruby errors outside of Rack? [See wiki](https://github.com/Sharagoz/rails_exception_handler/wiki/Manual-exception-handling-outside-of-rack)

## Compatiblity

The gem should work with all versions of Rails 3. It does not work with Rails 2.

See Travis-CI for info on which rubies it is tested against:
http://travis-ci.org/#!/Sharagoz/rails_exception_handler

## Installation
Add the line below to your gemfile and run bundler

```
gem 'rails_exception_handler', "~> 2"
```

Generate an initializer:

```
rails g rails_exception_handler:install
```

Open config/initializers/rails_exception_handler.rb, have a quick look and read on.

## Configuring the basics

### environments
An array of symbols that says which Rails environments you want the exception handler to run in.

```ruby
config.environments = [:production, :test, :development]
```

Default value: [:production]

### fallback_layout

```ruby
config.fallback_layout = 'home'
```

Default value: 'application'

The exception handler will always use the layout file of the controller action that was accessed when the error occured. However, when routing errors occures there are no controller action to get this layout from, so it falls back to the default 'application' layout that most apps have. If your application does not have a layout file called 'application', then you need to override this, otherwise a "missing layout" exception will occur.

### after_initialize

This is a callback that exists in case you need to do something right after the initializer has been run, for instance [interact with an authorization mechanism](https://github.com/Sharagoz/rails_exception_handler/wiki/Interaction-with-authorization-mechanisms)

```ruby
config.after_initialize do
  # additional setup
end
```

### responses and response_mapping

Note: public/500.html and public/400.html will be used if these exists. Remove these files before applying the configuration below.

Create a set of responses and then map specific exceptions to these responses. There needs to be a response called :default which is used for the exceptions that are not explicitly mapped to a response.

```ruby
config.responses = {
  :default => "<h1>500</h1><p>Internal server error</p>",
  :not_found => "<h1>404</h1><p>Page not found</p>",
  :wrong_token => "<h1>500</h1><p>There was a problem authenticating the submitted form. Reload the page and try again.</p>",
  :teapot => "<h1>418</h1><p>I'm a teapot</p>"
}
config.response_mapping = {
 'ActiveRecord::RecordNotFound' => :not_found,
 'ActionController:RoutingError' => :not_found,
 'AbstractController::ActionNotFound' => :not_found,
 'ActionController::InvalidAuthenticityToken' => :wrong_token,
 'Teapot::CoffeeGroundsNotSupported' => :teapot
}
```

# Gathering exception information

Gathering and storing exception information is optional, but still the main purpose of this exception handler.

The following four methods exists for extracting the information you need. You are given direct access to the relevant objects, which means full flexibility, but also more work on your part.
The initializer contains a basic suggestion, you can check out [the wiki](https://github.com/Sharagoz/rails_exception_handler/wiki/Extracting-exception-info)
for more options, or inspect the objects yourself with a tool like Pry to find what you need.

The "storage" hash below is the object that is sent to the storage strategy. Make sure the keys in the hash matches up with the names of the database fields.

```ruby
config.store_request_info do |storage,request|
end

config.store_exception_info do |storage,exception|
end

config.store_environment_info do |storage,env|
end

config.store_global_info do |storage|
end
```

### store_user_info

Having some way of identifying the user can be very useful at times, so I always store information on who generated the exception in applications that have a log in feature.
Since extracting current_user from the environment variable takes a little bit of work, this helper method exists to make it easier. The user info are stored in a field called "user_info".

```ruby
config.store_user_info = {:method => :current_user, :field => :login}
```

Default value: false (no info will be stored)
If you turn this on and the error is generated by a client that is not logged in, then "Anonymous" will be used.

# Storing the exception

No storage strategies are enabled by default. You can enable more than one storage strategy.

### Through active_record

```ruby
config.storage_strategies = [:active_record]
```
This means that the error reports will be stored through active record directly to a database. A new entry called **exception_database** is needed in **database.yml**:
For mysql the entry would look something like this:

```
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

You could of course store the error messages in the same database as the application uses, but one of the main purposes of this exception handler is to enable you to easily store error reports from many applications in the same database, so I recommend you set up a separate dedicated database for this.

The exception database needs a table called **error_messages**. Here's a migration script that you can use to create the table with the necessary fields required for the default configuration:

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
      t.string :doc_root

      t.timestamps
    end
  end

  def self.down
    drop_table :error_messages
  end
end
```

### Through mongoid

```ruby
config.storage_strategies = [:mongoid]
```
This means that the error reports will be stored through mongoid directly to MongoDB. No changes to your mongoid.yml are necessary.

Instead, in your configuration initializer, set the location where errors should be saved. Below is an example of the default when this option is left blank:

```ruby
config.mongoid_store_in database: :exception_database, collection: :error_message
```

Be sure to set username and password credentials if necessary! No migration script is necessary to run.

This can be used simultaneously with the active_record strategy, or any other strategy for that matter, if desired.


### Saving to the rails log

```ruby
config.storage_strategies = [:rails_log]
```

An error will be logged in the standard rails log. The log i located in the RAILS_ROOT/log directory and is named after the Rails environment.
Example of what a report might look like:

```
TARGET:     http://example.com/users
REFERER:    http://example.com/
PARAMS:     {"controller"=>"users", "action"=>"index"}
USER_AGENT: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30
USER_INFO:  matz
ActionView::Template::Error (ActionView::Template::Error):
activesupport (3.0.7) lib/active_support/whiny_nil.rb:48:in `method_missing'
actionpack (3.0.7) lib/action_view/template.rb:135:in `block in render'
activesupport (3.0.7) lib/active_support/notifications.rb:54:in `instrument'
(the rest of the stack trace has been omitted from the example)
```

### Sending the error report as an HTTP POST request to another application

```ruby
config.storage_strategies = [:remote_url => {:target => 'http://example.com/error_messages'}]
```

This option is meant for those who want to store the exception in a database table, but does not have direct access to the database itself, making active record store unsuitable. You need a web app on a server that has access to the database. An HTTP POST request will be sent to the specified URL with the error message as data.
If you use a Rails app at the other end you should simply be able to do _RailsExceptionHandler::ActiveRecord::ErrorMessage.create(params[:error_message])_ or _RailsExceptionHandler::Mongoid::ErrorMessage.create(params[:error_message])_ to save the report depending upon your database choice.

# Exception filters

Sometimes it is necessary to filter errors. All filters are disabled by default and I recommend you deploy your application this way initially, and then add filters as they become necessary.
The only reason I've ever wanted filtering have been due to what seem like poorly programmed web crawlers and black bots probing for security holes. If legitimate web crawlers are a problem for you, look into tweaking your robots.txt file before enabling exception filters.

### :all_404s

```ruby
config.filters = [:all_404s]
```

When turned on the following exceptions will no longer be stored: ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound
Consider this a last resort. You will miss all "real" 404s when this is turned on, like broken redirections.

### :anon_404s

```ruby
config.filters = [:anon_404s]
```

When turned on the following exceptions will no longer be stored unless a user is logged in: ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound

Note: This filter depends on config.store_user_info to figure out how to get access to the current_user object. This will be cleaned up in a future release.

### :no_referer_404s

```ruby
config.filters = [:no_referer_404s]
```

ActionController::RoutingError, AbstractController::ActionNotFound, ActiveRecord::RecordNotFound will be ignored if it was caused by a request without a referer.
This is very effective against bots. 99.9% of the time a routing error with no referer will be caused by a bot, and then once in a while it will be caused by a real user that happened to generate an error on the first page he opened (like a broken bookmark). You will get a lot less false positives with this filter than :all_404s.

### :user_agent_regxp

Legit software will usually add something to the user agent string to let you know who they are. You can use this to filter out the errors they generate, and be pretty sure you are not going to get any false positives.

```ruby
config.filters = [:user_agent_regxp => /\b(ZyBorg|Yandex|Jyxobot)\b/i]
```

If you (like me) dont know regular expressions by heart, then http://www.rubular.com/ is great tool to use when creating a regxp.

### :target_url_regxp

Sometimes black bots add a common user agent string and a referer to their requests to cloak themselfs, which makes it hard to filter them without filtering all routing errors. What you can often do is to filter on what they target, which is usually security holes in some widely used library/plugin. The example below will filter out all URLs containing ".php". This is the filter I most commonly use myself. Without it, it is only a matter of time before I'll one day get 200 exceptions in 10mins caused by a bot looking for security holes in myPhpAdmin or some other PHP library.

```ruby
config.filters = [:target_url_regxp => /\.php/i]
```

### :referer_url_regxp

Works the same way as :target_url_regxp. Enables you to get rid of error messages coming from spesific sources, like external links to assets that no longer exists.

```ruby
config.filters = [:referer_url_regxp => /\problematicreferer/i]
```

# Contributors

David Rice and James Harrison

Would you like to contribute? Here are some things on the todo list:

* A mongoid storage strategy for those that wish to use MongoDB
* An email storage strategy for those that wish to be notified of the exceptions through email

# Licence

Copyright © 2012 Bjørn Trondsen, released under the MIT license
