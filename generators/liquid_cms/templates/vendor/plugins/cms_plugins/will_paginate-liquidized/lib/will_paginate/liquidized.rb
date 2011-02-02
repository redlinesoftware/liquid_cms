module WillPaginate::Liquidized
  def self.included(base)
    WillPaginate::Collection.class_eval do 
      def to_liquid
        WillPaginate::CollectionDrop.new self    
      end

      def collect(&block)    
        dup.replace super.collect(&block)
      end
    end  
  end
  
  class CollectionDrop < Liquid::Drop
    attr_reader :source
  
    def initialize(source)
      @source = source
    end
    
    def [](*args)
      return @source[*args]
    end
    
    def method_missing(method, &block)
     allow = [:current_page, :per_page, :total_entries, :offset, :total_pages, 
              :previous_page, :next_page, :empty?, :length, :sort_by]
     unless allow.include? method
       super.method_missing method, &block
     else
        @source.send method, &block
      end
    end
  end
end
