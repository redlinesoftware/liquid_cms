module Cms
  class Page < ActiveRecord::Base
    set_table_name 'cms_pages'

    attr_accessible :name, :slug, :content, :layout_page_id, :published, :root, :updated_by

    NAME_REGEX = /^[^\/][a-zA-Z0-9_\-\.]+$/

    versioned

    belongs_to :layout_page, :class_name => self.to_s
    has_many :content_pages, :class_name => self.to_s, :foreign_key => 'layout_page_id', :dependent => :nullify, :order => 'name ASC'

    before_validation :clean_data
    before_save :verify_single_root

    validates_presence_of :content
#    validates_presence_of :slug, :message => "can't be blank for a published page", :if => proc{|page| page.published?}
    validates_format_of :name, :with => NAME_REGEX
    validates_uniqueness_of :name, :scope => (Cms.context_class ? :context_id : nil), :case_sensitive => false
    validates_uniqueness_of :slug, :scope => (Cms.context_class ? :context_id : nil), :case_sensitive => false, :allow_blank => true

    validates_each :slug do |record,attr,value|
      record.errors.add attr, "is reserved and can't be used for this page" if record.reserved_slug?
    end
    validates_each :slug, :published, :root do |record,attr,value|
      record.errors.add attr, "can't be set for a layout page" if value.present? && record.is_layout_page? 
    end

    scope :published, :conditions => {:published => true}
    scope :unpublished, :conditions => {:published => false}
    scope :layouts, :conditions => {:is_layout_page => true}
    scope :ordered, :order => 'name ASC'

    def to_s
      name
    end

    def reserved_slug?
      return false if self.slug.blank?

      # reserved paths
      return true if self.slug =~ /\A\/(stylesheets|scripts|images)\b/

      path_options = Rails.application.routes.recognize_path(slug)
      # if the :url option is nil, then one of the existing routes matched the slug
      return true if path_options[:url].nil?

      first_segment = (path_options[:url] || '/').split('/')[0]

      # if part of the path matches and of the route "controllers" then we have a route conflict
      Rails.application.routes.routes.any? do |r|
        r.path.split('/')[1] == first_segment
      end
    end

    def rendered_content(controller)
      render_options = {} #{:filters => [CmsFilters, AppFilters]}
      common_assigns = {'params' => ParamsDrop.new((controller.params || {}).except(:controller, :action)), 'site_url' => controller.request.protocol + controller.request.raw_host_with_port}

      context_obj = Cms::Context.new(Cms.context_class ? context : nil)

      # render the current page
      page = self
      template = Liquid::Template.parse(page.content)
      template.registers[:context] = context_obj
      template.registers[:controller] = controller
      content = template.render(common_assigns, render_options)
      common_assigns.update(template.instance_assigns)

      # and then render any layout files of the current page
      while page.layout_page do
        page = page.layout_page
        template = Liquid::Template.parse(page.content)
        template.registers[:context] = context_obj
        content = template.render({'content_for_layout' => content}.merge(common_assigns), render_options)
        common_assigns.update(template.instance_assigns)
      end

      return content
    end

    def content_type
      Cms::Editable.content_type name
    end 

    def url
      case content_type
      when 'text/css'
        "/cms/stylesheets/#{name}"
      when 'text/javascript'
        "/cms/javascripts/#{name}"
      else
        slug = read_attribute(:slug)
        slug.present? ? slug : "/#{name}"
      end
    end

    def content=(text)
      write_attribute :content, text
      self.is_layout_page = !(text =~ /\{\{\s?content_for_layout\s?\}\}/).blank?
    end

  protected
    def clean_data
      if slug.present?
        # remove leading and trailing slashes (will catch multiple /'s on each end and remove them)
        self.slug.gsub!(/^\/*/,'').gsub!(/\/*$/,'') if self.slug.length > 1
        # add a leading /
        self.slug = '/'+self.slug
      end
    end

    def verify_single_root
      # if this page is being set as root, remove root for an existing page if found
      if root?
        home = Cms.context_class ? context.pages.root : self.class.first(:conditions => {:root => true})
        home.update_attribute :root, false if home && home != self
      end
    end
  end
end
