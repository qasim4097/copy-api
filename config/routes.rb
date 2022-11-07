Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      get 'copy/', to: 'copy#index', as: 'copy'
      get 'copy/refresh', to: 'copy#refresh', as: 'refresh'
      get 'copy/:key', to: 'copy#find', as: 'find'
    end
  end
end
