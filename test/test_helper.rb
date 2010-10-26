ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'bundler'
Bundler.setup

$:.unshift File.dirname(__FILE__)

require "rails_app/config/environment"
require 'rails/test_help'
require 'ostruct'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), "rails_app/db/migrate/"), nil)

Factory.definition_file_paths << "#{File.dirname(__FILE__)}/factories"
Factory.find_definitions

module TestConfig
  mattr_reader :paperclip_test_root
  @@paperclip_test_root = File.join(File.expand_path(File.dirname(__FILE__)), 'rails_app', 'test', 'fixtures')
end

require 'test_helpers/login_methods'

class ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
end
