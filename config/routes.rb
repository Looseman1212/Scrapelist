Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'pages#home', as: 'home'
  get 'login', to: 'pages#login', as: 'login'

  get 'scrapelists', to: 'scrapelistprompts#index', as: 'all_scrapelists'
  get 'scrapelists/:id', to: 'scrapelistprompts#show', as: 'one_scrapelist'

  # this route is for debugging purposes
  get 'scrapelists/:id/test', to: 'scrapelistprompts#show_test', as: 'one_scrapelist_test'

  # resources :scrapelistprompts, only: [:index, :show]

  get 'scrapelist/choice_page', to: 'scrapelistprompts#choose', as: 'choice_page'

  get 'scrapelist/new_easy', to: 'scrapelistprompts#new_easy', as: 'new_scrapelist_easy'
  post 'scrapelist/new_easy', to: 'scrapelistprompts#create_easy', as: 'scrapelistprompts_easy'

  get 'scrapelist/new_picky', to: 'scrapelistprompts#new_picky', as: 'new_scrapelist_picky'
  post 'scrapelist/new_picky', to: 'scrapelistprompts#create_picky', as: 'scrapelistprompts'

  get 'scrapelist/:id/send_to_spotify', to: 'scrapelistprompts#send_to_spotify', as: 'send_to_spotify'
end
