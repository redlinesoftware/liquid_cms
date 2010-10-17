# Include hook code here
config.to_prepare do
  ApplicationController.helper(Cms::CommonHelper, Cms::AssetsHelper, Cms::ComponentsHelper, Cms::PagesHelper)
end

I18n.load_path += Dir[Rails.root.join('config', 'locales', 'cms', '*.{rb,yml}').to_s] 

require 'liquid_cms'

gem 'paperclip', '~> 2.3.1.1'
require 'paperclip'

gem 'vestal_versions', '~> 1.0.1'
require 'vestal_versions'

gem 'simple_form', '~> 1.0.4'
require 'simple_form'

gem 'rubyzip', '~> 0.9.1'
require 'zip/zip'

gem 'will_paginate', '~> 2.3.12'
require 'will_paginate'

require 'liquid'

# adds files to the load path
add_files_to_load_path = lambda {|dir|
  path = File.expand_path(dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
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
load_liquid_paths.call File.dirname(__FILE__)
# load the main apps paths next
load_liquid_paths.call Rails.root.to_s

ActiveSupport::Inflector.inflections do |inflect|
  inflect.human 'Cms::Page', 'Page'
  inflect.human 'Cms::Asset', 'Asset'
end
