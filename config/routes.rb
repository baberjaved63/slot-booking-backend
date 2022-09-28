Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "slots#index"

  resources "slots"

  mount ActionCable.server => '/cable'
end
