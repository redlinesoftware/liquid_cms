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
      !(asset_content_type =~ /icon$/).nil?
    end

  protected
    def process_check
      image? && !icon?
    end
  end
end
