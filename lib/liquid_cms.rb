require 'active_record/associations'
require 'dispatcher'

# LiquidCMS
module Cms
  autoload :Context, 'context'
  autoload :ContextAssociation, 'context_association'
  autoload :Association, 'association'

  mattr_accessor :context_foreign_key
  @@context_foreign_key = :context_id

  mattr_reader :context_class
  def self.context_class=(klass)
    @@context_class = klass
    Dispatcher.to_prepare {
      eval(klass.to_s).extend Cms::ContextAssociation

      # FIXME remove the :froeign_key because this should be context_id in the db
      Cms::Page.belongs_to  :context, :class_name => klass.to_s, :foreign_key => :dealer_id
      Cms::Asset.belongs_to :context, :class_name => klass.to_s, :foreign_key => :dealer_id
    }
  end
  @@context_class = nil

  def self.set_context(context, bind_to)
    bind_to.instance_variable_set :@cms_context, context
  end

  def self.global_route(route_map)
    route_map.connect '*url', :controller => 'cms/pages', :action => 'load'
  end

  def self.setup
    yield self
  end
end
