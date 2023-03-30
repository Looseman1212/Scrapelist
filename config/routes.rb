Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'pages#home', as: 'home'
  get 'scrapelists', to: 'scrapelistprompts#index', as: 'all_scrapelists'
  get 'scrapelists/:id', to: 'scrapelistprompts#show', as: 'one_scrapelist'
  # resources :scrapelistprompts, only: [:index, :show]
  get 'scrapelist/new_easy', to: 'scrapelistprompts#new_easy', as: 'new_scrapelist_easy'
  post 'scrapelists', to: 'scrapelistprompts#new_easy'
end
