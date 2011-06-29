class ErrorResponseController < ActionController::Base
  def index
    render(:text => "<h1>Det oppsto en feil</h1><p>Feilmeldingen har blitt logget</p>", :layout => 'layouts/application')
  end
end
