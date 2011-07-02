ExceptionHandlerTestApp::Application.routes.draw do
  match 'home/action_with_error' => 'home#action_with_error'
end
