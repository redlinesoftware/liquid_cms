require 'liquid_cms/role_authentication'
require 'liquid_cms/configuration'
require 'paperclip'

module Cms
  class Engine < Rails::Engine
    config.to_prepare do
      ApplicationController.helper(Cms::CommonHelper, Cms::AssetsHelper, Cms::ComponentsHelper, Cms::PagesHelper)
    end

    config.i18n.load_path += Dir[File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'locales', 'cms', '*.{rb,yml}'))]

    initializer "add liquid load paths" do
      if defined?(Liquid)
        # adds files to the load path
        add_files_to_load_path = lambda {|dir|
          path = File.expand_path(dir)
          $LOAD_PATH << path
          ActiveSupport::Dependencies.autoload_paths << path
          ActiveSupport::Dependencies.autoload_once_paths.delete path
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
    end
  end
end
