class Cms::Tag < ActiveRecord::Base
  unloadable

  set_table_name 'cms_tags'

  class << self
    def find_or_initialize_with_name_like(name)
      with_name_like(name).first || new(:name => name)
    end
  end

  has_many :taggings, :dependent => :destroy, :class_name => 'Cms::Tagging'

  validates_presence_of :name

  named_scope :with_name_like, lambda { |name| { :conditions => ["name like ?", name] } }

  def to_s
    name
  end
end
