ENV["RAILS_ENV"] = "test"

$:.unshift File.dirname(__FILE__)

require "rails_app/config/environment"
require 'test_help'

if ENV['NO_CONTEXT'] == 'true'
  Cms.setup do |config|
    config.context_class = nil
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), "rails_app/db/migrate/"), nil)

require 'rubygems'
require 'ostruct'
require 'shoulda'
require 'factory_girl'

Factory.definition_file_paths << "#{File.dirname(__FILE__)}/factories"
Factory.find_definitions

module TestConfig
  mattr_reader :paperclip_test_root
  @@paperclip_test_root = File.join(File.dirname(__FILE__), 'paperclip')
end

require 'test_helpers/login_methods'
require 'test_helpers/asset_helpers'
require 'test_helpers/component_helpers'

class ActionController::TestCase
  include AssetHelpers
end
class ActiveSupport::TestCase
  include AssetHelpers
  include ComponentHelpers
end


class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false
end
