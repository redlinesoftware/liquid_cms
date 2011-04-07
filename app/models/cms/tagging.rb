class Cms::Tagging < ActiveRecord::Base
  set_table_name 'cms_taggings'

  belongs_to :tag, :class_name => 'Cms::Tag'
  belongs_to :taggable, :polymorphic => true
end
