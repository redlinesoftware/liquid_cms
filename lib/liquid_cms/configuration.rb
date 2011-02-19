module Cms
  autoload :Context, 'liquid_cms/context'
  autoload :ContextAssociation, 'liquid_cms/context_association'
  autoload :Association, 'association'

  mattr_reader :context_class
  def self.context_class=(klass)
    @@context_class = klass
    return if klass.nil?

    eval(klass.to_s).extend Cms::ContextAssociation

    Cms::Page.belongs_to  :context, :class_name => klass.to_s
    Cms::Asset.belongs_to :context, :class_name => klass.to_s
  end
  @@context_class = nil

  def self.set_context(context, bind_to)
    return if @@context_class.nil?
    bind_to.instance_variable_set :@cms_context, context
  end

  def self.setup
    yield self
  end
end
