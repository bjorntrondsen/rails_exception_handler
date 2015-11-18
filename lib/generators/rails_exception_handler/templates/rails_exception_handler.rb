RailsExceptionHandler.configure do |config|

  # config.environments = [:development, :test, :production]                # Defaults to [:production]
  # config.fallback_layout = 'home'                                         # Defaults to 'application'

  # config.after_initialize do
  #   # This block will be called after the initialization is done.
  #   # Usefull for interaction with authentication mechanisms, which should
  #   # only happen when the exception handler is enabled.
  # end

  # No filters are enabled by default
  # config.filters = [
  #   :all_404s,
  #   :no_referer_404s,
  #   :anon_404s,
  #   {:user_agent_regxp => /\b(Baidu|Gigabot|Googlebot|libwww-per|lwp-trivial|msnbot|SiteUptime|Slurp|Wordpress|ZIBB|ZyBorg|Yandex|Jyxobot|Huaweisymantecspider|ApptusBot|TurnitinBot|DotBot|SiteBot)\b/i},
  #   {:target_url_regxp => /\.php/i},
  #   {:referer_url_regxp => /problematicreferer/i}
  # ]

  # Use mapping views or index. Defaults to false
  # config.mapping_views = true

  # All errors are mapped to the :default response unless overridden here
  config.response_mapping = {
    'ActiveRecord::RecordNotFound' => :not_found,
    'ActionController::RoutingError' => :not_found,
    'AbstractController::ActionNotFound' => :not_found
  }

  # Available options for storage strategies: [ :active_record, :rails_log, remote_url: { target: 'http://example.com' } ]
  config.storage_strategies = [:active_record]

  # Change database/table for the active_record storage strategy
  # config.active_record_store_in = {
  #  database: :exception_database,
  #  record_table: :error_messages
  # }

  config.store_request_info do |storage, request|
    storage[:target_url]  = request.url
    storage[:referer_url] = request.referer
    storage[:params]      = request.params.inspect
    storage[:user_agent]  = request.user_agent
  end

  config.store_exception_info do |storage, exception|
    storage[:class_name] = exception.class.to_s
    storage[:message]    = exception.to_s
    storage[:trace]      = exception.backtrace.join('\n')
  end

  config.store_environment_info do |storage, env|
    storage[:doc_root] = env['DOCUMENT_ROOT']
  end

  config.store_global_info do |storage|
    storage[:app_name]   = Rails.application.class.parent_name
  end

  # config.store_user_info = { method: :current_user, field: :login } # Helper method for easier access to current_user
end
