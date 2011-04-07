require 'rails/generators/active_record'

module LiquidCms
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "Install Liquid CMS files"
    source_root File.expand_path('templates', File.dirname(__FILE__))

    def copy_migration_file
      [{name: 'create_liquid_cms_setup', file: 'migration.rb'}, {name: 'create_liquid_cms_upgrade_rev1', file: 'migration_rev1.rb'}].each do |m|
        name = m[:name]
        if self.class.migration_exists?(File.join('db', 'migrate'), name).blank?
          migration_template m[:file], File.join('db', 'migrate', name)
        else
          puts "Migration '#{name}' already exists... skipping"
        end
      end
    end

    def self.next_migration_number(migration_dir)
      ActiveRecord::Generators::Base.next_migration_number migration_dir
    end

    def copy_setup_controller
      copy_file 'setup_controller.rb', File.join('app', 'controllers', 'cms', 'setup_controller.rb')
    end

    def create_asset_directories
      %w(assets components).each do |asset_dir|
        empty_directory File.join('public', 'cms', asset_dir)
      end
    end

    def copy_cms_plugins
      directory File.join('vendor', 'plugins'), nil, :verbose => false
    end

    def copy_assets
      directory File.join('public', 'cms'), nil, :verbose => false
    end
  end
end
