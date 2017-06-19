Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'home/controller_error' => 'home#controller_error'
  get 'home/model_error' => 'home#model_error'
  get 'home/view_error' => 'home#view_error'
  get 'home/custom_layout' => 'home#custom_layout'
  get 'home/syntax_error' => 'home#syntax_error'
end
