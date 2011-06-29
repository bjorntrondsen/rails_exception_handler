class ErrorMessage < ActiveRecord::Base
  establish_connection(
    :adapter => 'mysql',
    :host => '192.168.50.26',
    :username => 'root',
    :password => 'bits91HUX',
    :database => 'bits_railshq_production'
  )
end
