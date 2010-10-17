module Cms
  class CommonDrop < Liquid::Drop
    def initialize(record)
      @record = record
    end

    def before_method(method)
      @record[method].to_s
    end
  end
end
