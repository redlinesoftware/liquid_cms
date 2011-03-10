module CmsFilters
  module Protected
    extend ERB::Util
    extend ActionView::Helpers::TextHelper
    extend ActionView::Helpers::NumberHelper
    extend ActionView::Helpers::TagHelper
    extend ActionView::Helpers::AssetTagHelper
    extend ActionView::Helpers::UrlHelper
  end

  def money(value, precision = 0)
    Protected.number_to_currency value, :precision => precision
  end

  def json(value)
    value.to_json 
  end

  def url_encode(value)
    CGI::escape(value || '')
  end

  def url_decode(value)
    CGI::unescape(value || '')
  end

  def textilize(text, with_paragraphs = true)
    if with_paragraphs
      Protected.textilize text
    else
      Protected.textilize_without_paragraph text
    end
  end

  def script_tag(url)
    Protected.javascript_include_tag url
  end

  def stylesheet_tag(url)
    return '' if url.blank?
    Protected.stylesheet_link_tag url
  end

  def image_tag(url, title = nil, size = nil)
    return '' if url.blank?
    options = title.present? ? {:title => title, :alt => title} : {}
    options[:size] = size if size.present?
    Protected.image_tag url, options
  end

  def link_to(url, text = nil)
    Protected.link_to text, url
  end

  def assign_to(value, name)
    @context[name] = value
    nil
  end

  def paginate_collection(collection, limit, page)
    res = collection.paginate :page => page, :per_page => limit rescue WillPaginate::InvalidPage raise Liquid::SyntaxError, $!.message
    @context['paginate'] = {
      'total_pages' => res.total_pages,
      'current_page' => res.current_page,
      'previous_page' => res.previous_page,
      'next_page' => res.next_page,
    }
    res
  end

  def page_url(name)
    page = @context.registers[:context].pages.find_by_name name
    if page && page.url.present?
      page.url
    else
      raise Liquid::Error, "'#{name}' page not found."
    end
  end

  def asset_url(name)
    asset = @context.registers[:context].assets.find_by_asset_file_name name
    if asset
      asset.asset.url
    else
      raise Liquid::Error, "'#{name}' asset not found."
    end
  end

  def component_url(path)
    context = @context.registers[:context]
    "/" + Cms::Component.base_path(context).join(Cms::Component.component_path(context, path)).to_s
  end
end

Liquid::Template.register_filter CmsFilters
