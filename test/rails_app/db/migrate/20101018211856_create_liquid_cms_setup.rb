class CreateLiquidCmsSetup < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name, :null => false
      t.string :domain_name
      t.string :subdomain, :null => false
    end

    create_table :cms_pages do |t|
      t.string :name, :null => false
      t.string :slug
      t.text :content, :null => false      
      t.boolean :published, :default => false 
      t.boolean :root, :default => false
      t.boolean :editable, :default => false
      t.boolean :is_layout_page, :default => false

      t.references :context, :null => false if Cms.context_class
      t.references :layout_page

      t.timestamps
    end

    create_table :cms_assets do |t|
      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.datetime :asset_updated_at

      t.references :context, :null => false if Cms.context_class

      t.timestamps
    end

    create_table :versions do |t|
      t.belongs_to :versioned, :polymorphic => true
      t.belongs_to :user, :polymorphic => true
      t.string :user_name
      t.text :changes
      t.integer :number
      t.string :tag

      t.timestamps
    end

    change_table :versions do |t|
      t.index [:versioned_id, :versioned_type]
      t.index [:user_id, :user_type]
      t.index :user_name
      t.index :number
      t.index :tag
      t.index :created_at
    end
  end

  def self.down
    drop_table :cms_pages
    drop_table :cms_assets
    drop_table :versions
    drop_table :companies
  end
end
