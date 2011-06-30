# encoding: utf-8
class ErrorResponseController < ActionController::Base
  def index
    html = "<h1>Det oppsto en feil</h1>
            <p>Feilmeldingen har blitt logget sånn at den kan brukes til å løse eventuelle feil i applikasjonen.
            Hvis problemet vedvarer så kan du sende en e-post til <a href='mailto:railsadmin@bitsenter.no'>railsadmin@bitsenter.no</a></p>"
    render(:text => html, :layout => @_env['layout_for_exception_response'])
  end
end
