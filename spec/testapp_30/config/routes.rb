ExceptionHandlerTestApp::Application.routes.draw do
  match 'home/controller_error' => 'home#controller_error'
  match 'home/model_error' => 'home#model_error'
  match 'home/view_error' => 'home#view_error'
  match 'home/syntax_error' => 'home#syntax_error'
end
