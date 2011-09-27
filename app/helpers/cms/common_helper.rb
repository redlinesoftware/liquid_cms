module Cms::CommonHelper
  # js cookie accessor
  def cookie_jar(key)
    # if the cookie hasn't been set, need to return '{}' to return a proper hash
    # and if the cookie has been set, but is 'null', we need to then return a ruby hash
    # __CJ_ is the cookiejar js lib postfix value for cookies
    ActiveSupport::JSON.decode(cookies["__CJ_#{key}".to_sym] || '{}') || {}
  end

  def cms_icon(name, options = {})
    image_tag "/cms/images/icons/#{name}", options.merge(:size => '16x16')
  end

  def cms_flash_message
    type = (flash[:error] ? :error : :notice)
    flash[type].present? ? "humanMsg.displayMsg('#{escape_javascript(flash[type])}', '#{type}')" : nil
  end

  def load_cms_flash_message
    msg = cms_flash_message
    msg.present? ? javascript_tag("document.observe('dom:loaded', function(){ #{msg} })") : nil
  end

  def cms_row_class
    cycle 'dark', 'light'
  end

  def cms_ajax_update_form(page, object, path)
    if object.errors.empty?
      page << cms_flash_message
    else
      page.replace_html 'content', :file => "cms/#{path}/edit.html.erb"
    end
  end

  def codemirror_edit(content_type, form, content_id, use_ajax = true)
    mode = nil

    case content_type
    when "text/css"
      mode = 'css'
      content_for :cms_styles do
        javascript_include_tag '/cms/codemirror/mode/css/css'
      end
    when "text/javascript"
      mode = 'javascript'
      content_for :cms_styles do
        javascript_include_tag '/cms/codemirror/mode/javascript/javascript'
      end
    else
      mode = 'htmlmixed'
      content_for :cms_styles do
        javascript_include_tag '/cms/codemirror/mode/htmlmixed/htmlmixed'
      end
    end

    javascript_tag %(initCodemirror('#{mode}', $$('#{form}').first(), $('#{content_id}'), #{use_ajax}))
  end

  def file_type_icon(file_name)
    icon = case File.extname(file_name).downcase
    when ".xls"
      'page_white_excel.png'
    when ".doc"
      'page_white_word.png'
    when ".pdf"
      'page_white_acrobat.png'
    when ".zip"
      'page_white_compressed.png'
    when ".ppt"
      'page_white_powerpoint.png'
    when /\.(ico|bmp|gif|jpg|jpeg|png)$/
      'page_white_camera.png'
    when ".js"
      'script.png'
    when ".css"
      'css.png'
    when ".xml"
      'xhtml.png'
    else
      'page_white.png'
    end

    cms_icon(icon)
  end

  def page_icon(page)
    icon = case page.content_type
    when 'text/css'
      'css.png'
    when 'text/javascript'
      'script.png'
    when 'text/xml'
      'xhtml.png'
    when 'text/plain'
      'page_white.png'
    else
      'html.png'
    end 

    cms_icon(icon)
  end

  def asset_preview_option
    cookie_jar('toggle')['on'] == false ? 'style="display:none"' : ''
  end
end
