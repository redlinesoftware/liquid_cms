class CreateLiquidCmsUpgradeRev2 < ActiveRecord::Migration
  def self.up
    change_table :cms_assets do |t|
      t.text :cms_asset_dimensions # serialized yaml
    end
  end

  def self.down
    change_table :cms_assets do |t|
      t.remove :cms_asset_dimensions
    end
  end
end
