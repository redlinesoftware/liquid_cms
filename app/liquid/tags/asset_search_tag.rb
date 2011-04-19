# Syntax
# {% asset_data tag'test', as:'sale_vehicles' %}

class AssetDataTag < Cms::DataTag
  def get_data
    raise Liquid::ArgumentError.new("The required 'tag' parameter is missing.") if options[:tag].blank?

    collection = uses_random do |random_func|
      assets = context_object.assets.tagged_with(options[:tag])

      assets = if options[:random] == true
        assets.order(random_func)
      else
        assets.order('cms_assets.created_at ASC')
      end

      assets = assets.limit(options[:limit]) if options[:limit]

      assets.all
    end

    yield 'assets', collection
  end
end

Liquid::Template.register_tag('asset_data', AssetDataTag)
