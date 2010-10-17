module Cms::CommonHelper
  def cms_icon(name, options = {})
    image_tag "/cms/images/icons/#{name}", options.merge(:size => '16x16')
  end

  def cms_flash_message
    type = (flash[:error] ? :error : :notice)
    javascript_tag("document.observe('dom:loaded', function(){ humanMsg.displayMsg('#{escape_javascript(flash[type])}', '#{type}');})") if flash[type].present?
  end

  def cms_row_class
    cycle 'dark', 'light'
  end

  def codemirror_edit(content_type, form, content_id)
    js_options = case content_type
    when "text/css"
      <<-JS
      parserfile: ["../../javascripts/parseliquid.js", "parsecss.js"],
      stylesheet: ["/cms/codemirror/css/csscolors.css", "/cms/stylesheets/liquidcolors.css"],
      JS
    when "text/javascript"
      <<-JS
      parserfile: ["../../javascripts/parseliquid.js", "tokenizejavascript.js", "parsejavascript.js"],
      stylesheet: ["/cms/codemirror/css/jscolors.css", "/cms/stylesheets/liquidcolors.css"],
      JS
    else
      <<-JS
      parserfile: ["../../javascripts/parseliquid.js"],
      stylesheet: ["/cms/codemirror/css/xmlcolors.css", "/cms/stylesheets/liquidcolors.css"],
      JS
    end

    javascript_tag do
      <<-JS
      var editor = CodeMirror.fromTextArea("#{content_id}", {
        #{js_options}
        path: "/cms/codemirror/js/",
        textWrapping: false,
        height: '600px',
        saveFunction: function() {
          var form = $$('#{form}').first();
          $('#{content_id}').setValue(editor.getCode());
          form.submit();
        }
      });
      JS
    end
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
    # __CJ_ is the cookiejar js lib postfix value for cookies
    ActiveSupport::JSON.decode(cookies[:__CJ_toggle] || '{}')['on'] == false ? 'style="display:none"' : ''
  end
end
