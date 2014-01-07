class RailsExceptionHandler::Mongoid
  class ErrorMessage
    #if(defined?(Mongoid) && RailsExceptionHandler.configuration.activate? && RailsExceptionHandler.configuration.mongoid?)
    if defined?(Mongoid)
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in({:database => :exception_database, :collection => :error_message}.merge(RailsExceptionHandler.configuration.mongoid_store_in || {}))

      field :class_name, :type => String
      field :message, :type => String
      field :trace, :type => String
      field :target_url, :type => String
      field :referer_url, :type => String
      field :user_agent, :type => String
      field :user_info, :type => String
      field :app_name, :type => String
      field :doc_root, :type => String
      # Wish this could be a Hash, but since the legacy code expects that Hash.inspect is done (and they are parameters sent by the client)
      # it is not safe to eval it to transform it back into a Hash. Also, if config.store_request_info block did not perform inspect,
      # it could not be used by both Mongoid and any other storage strategy since those storage strategies would be responsible for
      # ensuring inspect were called. Possibly in a future major release this can be switched, though not sure if any benefit will
      # actually be gained from changing the type.
      field :params, :type => String
    end
  end

end
