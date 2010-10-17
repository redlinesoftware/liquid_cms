ActionController::Routing::Routes.draw do |map|
  map.namespace :cms do |cms|
    cms.resources :components, :only => [], :collection => {:upload => :post}
    cms.connect 'components/:action/*url', :controller => 'components'
    cms.resources :assets, :except => :index
    cms.resources :pages, :except => [:index, :show]
    cms.documentation 'documentation', :controller => 'documentation', :action => 'index'
    cms.connect ':path/:id.:format', :controller => 'pages', :action => 'page_asset', :requirements => {:path => /javascripts|stylesheets/}

    cms.root :controller => :main, :action => :index
  end
end
