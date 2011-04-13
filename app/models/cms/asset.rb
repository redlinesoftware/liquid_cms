module Cms
  class Asset < ActiveRecord::Base
    unloadable

    set_table_name 'cms_assets'

    include Cms::Taggable
    define_tag_association :assets

    def self.tags_for_context(context)
      common_options = {:order => 'name ASC'}
      context.object ? Cms::Tag.all({:include => :assets, :conditions => {'cms_assets.context_id' => context.object.id}}.merge(common_options)) : Cms::Tag.all(common_options)
    end

    class Meta
      attr_reader :name, :value, :errors

      def initialize(data)
        @name, @value = data[:name], data[:value]
        @errors = ActiveRecord::Errors.new(self)
      end

      def valid?
        validate
        errors.empty?
      end

      def validate
        errors.clear
        if @name.blank?
          errors.add :name, 'must be set'
        else
          errors.add :name, "is an invalid format" if (@name =~ /^[a-z]+[a-z0-9_]*$/).nil?
        end
      end
    end

    serialize :meta_data

    has_attached_file :asset,
      :styles => { :tiny => '50x50>', :thumb => '100x100>', :large => '200x200>', :custom => Proc.new{|instance| custom_dimensions(instance)} },
      :convert_options => {:all => '-strip -quality 90'},
      :path => ":rails_root/public/cms/assets/:id/:style/:filename",
      :url => "/cms/assets/:id/:style/:filename"

    validates_attachment_presence :asset
    validate :meta_data_check

    named_scope :ordered, :order => 'asset_file_name ASC'

    after_save :reprocess_custom_dimensions
    before_post_process :process_check

    def to_s
      asset_file_name
    end

    def self.context_tags(context)
      if context
        Tag.all :joins => 'inner join taggings on taggings.tag_id = tags.id inner join cms_assets on taggings.taggable_id = cms_assets.id', :conditions => {'cms_assets.context_id' => context.id}
      else
        Tag.all
      end
    end

    def image?
      !(asset_content_type =~ /^image.*/).blank?
    end

    def icon?
      # accepts ico or icon
      !(asset_content_type =~ /icon?$/).blank?
    end

    def editable?
      !(asset_content_type =~ /(javascript|css|xml|html)$/).blank?
    end

    def file_content
      read
    end

    def file_content=(content)
      write content
    end

    def meta
      return @_meta if @_meta.present?
      @_meta = (meta_data || []).collect{|m| Meta.new(m)}
    end

    def meta=(data)
      # reset the cached meta collection
      @_meta = nil

      # data ex:
      # {"new_1301457489798"=>{"name"=>"test1", "value"=>"test1"}, "new_1301457493800"=>{"name"=>"test2", "value"=>"test2"}}
      # converted to:
      # [{"name"=>"test1", "value"=>"test1"}, {"name"=>"test2", "value"=>"test2"}]
      # strip spaces of name and value
      temp_data = data.to_a.sort{|a,b| a.first <=> b.first}.collect{|a| h = a[1]; {:name => h[:name].strip, :value => h[:value].strip} }
      # remove any elements that have both name and value blank
      temp_data = temp_data.reject{|d| d[:name].blank? && d[:value].blank?}

      self.meta_data = temp_data
    end

    def to_liquid
      Cms::AssetDrop.new(self)
    end

  protected
    def read
      return '' if !editable?
      asset.to_file(:original).read
    end

    def write(content)
      return false if content.blank? || !editable?

      fname = asset.path(:original)
      File.exist?(fname).tap do |exist|
        File.open(fname, 'w') do |f|
          f.puts content
        end if exist
      end
    end

    def meta_data_check
      if !meta.find_all{|m| !m.valid?}.empty?
        errors.add :meta_data, "is invalid"
      end
    end

    def self.custom_dimensions(record)
      if !record.custom_width.to_i.zero? && !record.custom_height.to_i.zero?
        "#{record.custom_width}x#{record.custom_height}>"
      else
        ''
      end
    end

    def process_check
      image? && !icon?
    end

    def reprocess_custom_dimensions
      if custom_height_changed? || custom_width_changed?
        asset.reprocess!
      end
    end
  end
end
