Rails.application.routes.draw do
  devise_for :users,
    controllers: { registrations: "registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # swipe
  get "/swipe", to: "posts#swipe"

  get "/users/:id",to: "users#show", as: "user"
  get "/users",to: "users#index"

  resources :posts, only: %i(new create index show destroy) do
    resources :arts, only: %i(create)
  end

  resources :chat_rooms, only:[:create, :show]
  # Defines the root path route ("/")
  root "posts#index"
end
