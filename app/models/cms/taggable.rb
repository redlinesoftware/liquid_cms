module Cms::Taggable
  class TagList < Array
    def initialize(list)
      list = list.is_a?(Array) ? list : list.split(/[,\W]+/).collect(&:strip).reject(&:blank?).collect(&:downcase)
      super
    end
    
    def to_s
      join ', '
    end
  end

  def self.included(klass)
    klass.extend TaggableMethods::ClassMethods

    klass.class_eval do
      include TaggableMethods::InstanceMethods

      has_many :taggings, :as => :taggable, :dependent => :destroy, :class_name => 'Cms::Tagging'
      has_many :tags, :through => :taggings

      after_save :save_tags
    end
  end

  module TaggableMethods
    module ClassMethods
      def define_tag_association(assoc)
        source_klass = self.to_s
        Cms::Tag.class_eval do
          has_many assoc, :through => :taggings, :source => :taggable, :source_type => source_klass
        end

        self.scope :tagged_with, lambda{|tag| {:include => :tags, :conditions => ['cms_tags.name like ?', tag.to_s]}}
        self.scope :tagged, :joins => "left outer join cms_taggings on cms_taggings.taggable_id = #{table_name}.id", :conditions => 'cms_taggings.id is not null'
        self.scope :untagged, :joins => "left outer join cms_taggings on cms_taggings.taggable_id = #{table_name}.id", :conditions => 'cms_taggings.id is null'
      end
    end

    module InstanceMethods
      def tag_list
        get_tag_list
      end

      def tag_list=(new_list)
        set_tag_list new_list
      end

    protected
      def set_tag_list(list)
        @_tag_list = TagList.new(list)
      end

      def get_tag_list
        set_tag_list(tags.map(&:name)) if @_tag_list.nil?
        @_tag_list
      end
      
      def save_tags
        delete_unused_tags
        add_new_tags

        taggings.each(&:save)
      end
      
      def delete_unused_tags
        tags.each { |t| tags.delete(t) unless get_tag_list.include?(t.name) }
      end

      def add_new_tags
        tag_names = tags.map(&:name)
        get_tag_list.each do |tag_name| 
          tags << Cms::Tag.find_or_initialize_with_name_like(tag_name) unless tag_names.include?(tag_name)
        end
      end
    end
  end
end
