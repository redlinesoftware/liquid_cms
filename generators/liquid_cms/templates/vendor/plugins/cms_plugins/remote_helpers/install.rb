require 'ftools'

plugin_dir = File.dirname(File.expand_path(__FILE__))
File.copy File.join(plugin_dir, 'images', 'indicator.gif'), File.join(RAILS_ROOT, 'public', 'images', 'indicator.gif')
