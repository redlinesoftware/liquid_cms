Rails.application.routes.draw do
  namespace :cms do
    post 'components/upload'

    controller :components do
      match '/components/:action/*url'
    end

    resources :assets, :except => :index
    resources :pages, :except => [:index, :show] do
      collection do
        match :search, :via => [:get, :post]
      end
    end
    resources :documentation, :only => :index
    match ':path/:id.:format', :to => 'pages#page_asset', :requirements => {:path => /javascripts|stylesheets/}

    root :to => 'main#index'
  end

  match '(*url)', :to => 'cms/pages#load'
end
