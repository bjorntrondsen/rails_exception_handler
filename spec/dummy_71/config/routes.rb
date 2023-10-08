Rails.application.routes.draw do
  get 'home/controller_error' => 'home#controller_error'
  get 'home/model_error' => 'home#model_error'
  get 'home/view_error' => 'home#view_error'
  get 'home/custom_layout' => 'home#custom_layout'
  get 'home/syntax_error' => 'home#syntax_error'
end
