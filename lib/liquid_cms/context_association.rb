module Cms
  module ContextAssociation
    def ContextAssociation.extended(other)
      other.has_many :pages, :class_name => 'Cms::Page', :dependent => :destroy, :foreign_key => :context_id do
        def root
          first :conditions => {:root => true}
        end
      end
      other.has_many :assets, :class_name => 'Cms::Asset', :dependent => :destroy, :foreign_key => :context_id
    end
  end
end
