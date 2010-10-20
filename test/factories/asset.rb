Factory.define :image_asset, :class => Cms::Asset do |a|
  a.asset_file_name 'test.png'
  a.asset_content_type 'image/png'
  a.asset_file_size 1.megabyte
  a.asset_updated_at Time.now
end

Factory.define :pdf_asset, :class => Cms::Asset do |a|
  a.asset_file_name 'test.pdf'
  a.asset_content_type 'application/pdf'
  a.asset_file_size 1.megabyte
  a.asset_updated_at Time.now
end
