require 'cms_common_drop'

class Cms::AssetDrop < Cms::CommonDrop
  def meta
    {}.tap do |h|
      (@record.meta_data || []).each do |mh|
        h[mh[:name]] = mh[:value]
      end
    end
  end

  def image
    @record.asset
  end
end
