require 'cms_common_drop'

module Cms
  class ParamsDrop < CommonDrop
    # type needs to be special cased
    def type
      @record[:type]
    end
    
    def url
      (@record[:url] || '').split('/')
    end
  end
end
