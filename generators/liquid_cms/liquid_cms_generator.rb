require 'fileutils'

class LiquidCmsGenerator < Rails::Generator::Base
  ASSET_DIRS = %w(images stylesheets javascripts)

  def manifest
    record do |m|
      m.migration_template 'migration.rb', File.join('db', 'migrate'), :migration_file_name => 'create_liquid_cms_setup'

      m.directory File.join('config', 'initializers', 'cms')
      %w(liquid_cms.rb simple_form.rb simple_form_updates.rb vestal_versions.rb remote_indicator.rb).each do |file|
        m.file File.join('config', 'initializers', 'cms', file), File.join('config', 'initializers', 'cms', file)
      end

      m.directory File.join('app', 'controllers', 'cms')
      m.file 'setup_controller.rb', File.join('app', 'controllers', 'cms', 'setup_controller.rb')

      %w(filters tags drops).each do |liquid_dir|
        m.directory File.join('app', 'liquid', liquid_dir)
      end

      m.directory File.join('config', 'locales', 'cms')
      m.file File.join('config', 'locales', 'cms', 'en.yml'), File.join('config', 'locales', 'cms', 'en.yml')

      (ASSET_DIRS + %w(codemirror assets components)).each do |asset_dir|
        m.directory File.join('public', 'cms', asset_dir)
      end

      m.directory File.join('vendor', 'plugins', 'cms_plugins')
      logger.info "copying cms plugins to 'vendor/cms_plugins'"
      FileUtils.cp_r File.join(source_root, 'vendor', 'plugins', 'cms_plugins'), File.join(destination_root, 'vendor', 'plugins')

      logger.info "copying assets to 'public/cms'"
      ASSET_DIRS.each do |asset_dir|
        FileUtils.rm_rf File.join(destination_root, 'public', 'cms', asset_dir)
      end
      FileUtils.cp_r File.join(source_root, 'public', 'cms'), File.join(destination_root, 'public')

      # add the global cms route to the apps main route file
      sentinel = 'end'
      logger.route "Cms.global_route map"
      m.gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)}\Z)/mi do |match|
        "\n\t# This must be the last defined route in order for the cms to load pages properly.\n\tCms.global_route map\n#{sentinel}"
      end
    end
  end
end
