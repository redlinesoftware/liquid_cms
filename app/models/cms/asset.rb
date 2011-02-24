module Cms
  class Asset < ActiveRecord::Base
    set_table_name 'cms_assets'

    has_attached_file :asset,
      :styles => { :tiny => '50x50>', :thumb => '100x100>' }, #:custom => Proc.new { |instance| "#{instance.photo_width}x#{instance.photo_height}>" } },
      :path => ":rails_root/public/cms/assets/:id/:style/:filename",
      :url => "/cms/assets/:id/:style/:filename"

    validates_attachment_presence :asset

    named_scope :ordered, :order => 'asset_file_name ASC'

    before_post_process :process_check

    def to_s
      asset_file_name
    end

    def image?
      !(asset_content_type =~ /^image.*/).nil?
    end

    def icon?
      # accepts ico or icon
      !(asset_content_type =~ /icon?$/).nil?
    end

    def editable?
      !(asset_content_type =~ /(javascript|css|xml|html)$/).nil?
    end

    def read
      return '' if !editable?
      asset.to_file(:original).read
    end

    def write(content)
      return false if content.blank? || !editable?

      fname = asset.path(:original)
      if File.exist?(fname)
        File.open(fname, 'w') do |f|
          f.puts content
        end
      else
        false
      end
    end

  protected
    def process_check
      image? && !icon?
    end
  end
end
