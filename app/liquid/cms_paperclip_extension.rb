module Paperclip
  class Attachment
    extend ActiveSupport::Memoizable

    def to_liquid
      style_hash = {}

      style_hash.tap do |h|
        all_styles = self.styles.keys + ['original']
        all_styles.each do |style|
          h[style.to_s] = find_geometry_dims(style)
          h[style.to_s]['url'] = self.url(style) if h[style.to_s].present?
        end
      end

      save_geometry_dims style_hash

      style_hash
    end
    memoize :to_liquid

    # clear out the dimension attribute when post processing
    # it'll be updated on the next render via to_liquid
    def post_process_with_dimension_attribute_clear
      key = dimension_key

      if instance.has_attribute?(key)
        instance.send("#{key}=", nil)
      end

      post_process_without_dimension_attribute_clear
    end

    alias_method_chain :post_process, :dimension_attribute_clear

  protected
    def dimension_key
      "cms_#{name}_dimensions"
    end

    def find_geometry_dims(style)
      key = dimension_key

      if instance.has_attribute?(key)
        # dimension attr found
        values = YAML::load(instance.send(key) || '{}')
        if values.blank?
          # no saved entry
          geometry_dims(style)
        else
          # saved entry
          dimensions = values[style.to_s]
          if dimensions.blank?
            # empty dimensions for the given style
            geometry_dims(style)
          else
            # valid dimensions for the given style
            {'width' => dimensions['width'].to_i, 'height' => dimensions['height'].to_i}
          end
        end
      else
        # no dimensions found
        geometry_dims(style)
      end
    end

    def save_geometry_dims(style_hash)
      key = dimension_key

      if instance.has_attribute?(key) && YAML::load(instance.send(key) || '{}').all?{|k,v| v.blank?} && style_hash.present?
        # deep copy hash
        temp_hash = Marshal.load(Marshal.dump(style_hash))
        # remove blank styles
        temp_hash.delete_if{|k,v| v.blank?}
        # and remove the urls
        temp_hash.each{|k,v| v.delete_if{|k2,v2| k2 == 'url'}}

        instance.update_attribute key, temp_hash.to_yaml if temp_hash.present?
      end
    end

    def geometry_dims(style)
      g = Paperclip::Geometry.from_file(self.path(style)) rescue nil
      g.nil? ? {} : {'width' => g.width.to_i, 'height' => g.height.to_i}
    end
  end
end
