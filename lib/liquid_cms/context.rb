require 'liquid_cms/context_association'

module Cms
  class Context
    attr_reader :object

    def initialize(context = nil)
      @object = context
    end

    def pages
      @object ? @object.pages : Cms::Page.scoped(:extend => PageAssociationMethods)
    end

    def assets
      @object ? @object.assets : Cms::Asset.scoped(nil)
    end
  end
end
