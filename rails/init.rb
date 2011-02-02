require 'liquid_cms'
require 'vestal_versions'
require 'simple_form'
require 'zip/zip'
require 'will_paginate'
require 'redcloth'

config.to_prepare do
  ApplicationController.helper(Cms::CommonHelper, Cms::AssetsHelper, Cms::ComponentsHelper, Cms::PagesHelper)
end

I18n.load_path += Dir[Rails.root.join('config', 'locales', 'cms', '*.{rb,yml}').to_s] 

if defined?(Liquid)
  # adds files to the load path
  add_files_to_load_path = lambda {|dir|
    path = File.expand_path(dir)
    $LOAD_PATH << path
    if ActiveSupport::Dependencies.respond_to?(:autoload_paths)
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    else
      ActiveSupport::Dependencies.load_paths << path
      ActiveSupport::Dependencies.load_once_paths.delete(path)
    end
    Dir[File.join(path, '*.rb')].each{|f| require f}
  }

  # add liquid files to load path
  load_liquid_paths = lambda {|base|
    add_files_to_load_path.call File.join(base, 'app', 'liquid')
    %w{filters tags drops}.each do |dir|
      add_files_to_load_path.call File.join(base, 'app', 'liquid', dir)
    end
  }

  # load the cms paths first so that the main app can make use of existing classes
  load_liquid_paths.call File.join(File.dirname(__FILE__), '..')
  # load the main apps paths next
  load_liquid_paths.call Rails.root.to_s
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.human 'Cms::Page', 'Page'
  inflect.human 'Cms::Asset', 'Asset'
end