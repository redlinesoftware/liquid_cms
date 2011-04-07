class CreateLiquidCmsUpgradeRev1 < ActiveRecord::Migration
  def self.up
    change_table :cms_assets do |t|
      t.integer :custom_height
      t.integer :custom_width
      t.text :meta_data # serialized yaml
    end

    drop_table :versions

    create_table :cms_tags do |t|
      t.column :name, :string
    end
    
    create_table :cms_taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      t.column :taggable_type, :string
      
      t.column :created_at, :datetime
    end
    
    add_index :cms_taggings, :tag_id
    add_index :cms_taggings, [:taggable_id, :taggable_type]
  end

  def self.down
    drop_table :cms_taggings
    drop_table :cms_tags

    create_table :versions do |t|
    end

    change_table :cms_assets do |t|
      t.remove :custom_height, :custom_width, :meta_data
    end
  end
end
