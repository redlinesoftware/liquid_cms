ENV["RAILS_ENV"] = "test"

$:.unshift File.dirname(__FILE__)

require "rails_app/config/environment"
require 'test_help'
require 'ostruct'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Migrator.migrate(File.expand_path("rails_app/db/migrate/"), nil)

require 'rubygems'

require 'shoulda'
require 'factory_girl'

Factory.definition_file_paths << "#{File.dirname(__FILE__)}/factories"
Factory.find_definitions

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
end
