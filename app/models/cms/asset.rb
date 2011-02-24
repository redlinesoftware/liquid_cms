module Cms
  class Asset < ActiveRecord::Base
    set_table_name 'cms_assets'

    has_attached_file :asset,
      :styles => { :tiny => '50x50>', :thumb => '100x100>' }, #:custom => Proc.new { |instance| "#{instance.photo_width}x#{instance.photo_height}>" } },
      :path => ":rails_root/public/cms/assets/:id/:style/:filename",
      :url => "/cms/assets/:id/:style/:filename"

    validates_attachment_presence :asset

    scope :ordered, :order => 'asset_file_name ASC'

    before_post_process :process_check

    def to_s
      asset_file_name
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

  protected
    def process_check
      image? && !icon?
    end
  end
end
