module Paperclip
  class Attachment
    extend ActiveSupport::Memoizable

    def to_liquid
      {}.tap do |h|
        all_styles = self.styles.keys + ['original']
        all_styles.each do |style|
          g = Paperclip::Geometry.from_file(self.path(style)) rescue nil
          h[style] = {'width' => g.width.to_i, 'height' => g.height.to_i, 'url' => self.url(style)} unless g.nil?
        end
      end
    end
    memoize :to_liquid
  end
end
