# Syntax
# {% asset_data tag'test', as:'sale_vehicles' %}

class AssetDataTag < Cms::DataTag
  def get_data
    raise Liquid::ArgumentError.new("The required 'tag' parameter is missing.") if options[:tag].blank?

    assets = context_object.assets.tagged_with(options[:tag]).scoped(:order => 'cms_assets.created_at DESC')
    #assets = assets.scoped(:order => 'rand()') if options[:random] == true
    #assets = assets.scoped(:limit => options[:limit]) if options[:limit]

    yield 'assets', assets.all
  end
end

Liquid::Template.register_tag('asset_data', AssetDataTag)
