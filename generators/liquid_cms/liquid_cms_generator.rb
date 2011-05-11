require File.expand_path('../lib/insert_commands', __FILE__)

class LiquidCmsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # migrations
      m.migration_template 'migration.rb', File.join('db', 'migrate'), :migration_file_name => 'create_liquid_cms_setup'
      m.migration_template 'migration_rev1.rb', File.join('db', 'migrate'), :migration_file_name => 'create_liquid_cms_upgrade_rev1'
      m.migration_template 'migration_rev2.rb', File.join('db', 'migrate'), :migration_file_name => 'create_liquid_cms_upgrade_rev2'

      # initializers
      m.directory File.join('config', 'initializers', 'cms')
      %w(liquid_cms.rb simple_form.rb simple_form_updates.rb remote_indicator.rb).each do |file|
        m.file File.join('config', 'initializers', 'cms', file), File.join('config', 'initializers', 'cms', file)
      end

      # old files that need to be removed so that the app can run properly
      m.delete File.join('config', 'initializers', 'cms', 'vestal_versions.rb')

      # cms controllers
      m.directory File.join('app', 'controllers', 'cms')
      m.file 'setup_controller.rb', File.join('app', 'controllers', 'cms', 'setup_controller.rb')

      # liquid files
      m.directory File.join('app', 'liquid')
      %w(filters tags drops).each do |liquid_dir|
        m.directory File.join('app', 'liquid', liquid_dir)
      end

      # locales
      m.directory File.join('config', 'locales', 'cms')
      m.file File.join('config', 'locales', 'cms', 'en.yml'), File.join('config', 'locales', 'cms', 'en.yml')

      # plugins
      m.copy_files File.join('vendor', 'plugins'), 'cms_plugins'

      # user generated assets
      m.directory File.join('public', 'cms')
      %w(assets components).each do |asset_dir|
        m.directory File.join('public', 'cms', asset_dir)
      end
      
      # main assets
      Dir[File.join(source_root, 'public', 'cms', '*')].each do |asset_dir|
        m.copy_files File.join('public', 'cms'), File.basename(asset_dir)
      end

      # add the global cms route to the apps main route file... this must be the last route in the file (lowest priority)
      logger.route "Cms.global_route map"
      add_route m

      # add paperclip to the applications environment.rb file due to some loading issues
      logger.gem "config.gem 'paperclip'"
      add_gem m, 'paperclip', '~> 2.3.1'
      logger.gem "config.gem 'simple_form'"
      add_gem m, 'simple_form', '1.0.4'
    end
  end

  def add_route(m)
    sentinel = 'end'
    line = "\n\t# This must be the last defined route in order for the cms to load pages properly.\n\tCms.global_route map\n#{sentinel}"
    unless File.read(destination_path('config/routes.rb')).include?(line)
      m.gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)}\Z)/mi do |match|
        line
      end
    end
  end

  def add_gem(m, gem, version)
    sentinel = "end"
    line = "config.gem '#{gem}'"
    unless File.read(destination_path('config/environment.rb')).include?(line)
      m.gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)}\Z)/mi do |match|
        "\n\t# liquid_cms dependency\n\t#{line}, :version => '#{version}'\n#{sentinel}"
      end
    end
  end
end
