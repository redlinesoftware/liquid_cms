module WillPaginate::Liquidized   
  module ViewHelpers
    include WillPaginate::ViewHelpers
    
    #def will_paginate_liquid(collection, anchor = nil, prev_label = nil, next_label = nil)      
    def paginate_links(collection, anchor = nil, prev_label = nil, next_label = nil)      
      opts = {}
      opts[:previous_label] = prev_label if prev_label
      opts[:next_label]     = next_label if next_label      
      opts[:params]         = {:anchor => anchor} if anchor
      opts[:controller]     = @context.registers[:controller]
      
      with_renderer 'WillPaginate::Liquidized::LinkRenderer' do 
        will_paginate *[collection, opts].compact
      end
    end
    
  protected
    def with_renderer(renderer)
      old_renderer, options[:renderer] = options[:renderer], renderer
      result = yield
      options[:renderer] = old_renderer
      result
    end
    
    def options
      WillPaginate::ViewHelpers.pagination_options
    end
  end

  class LinkRenderer < WillPaginate::LinkRenderer
    
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper 

    def to_html
      return "<p><strong style=\"color:red;\">(Will Paginate Liquidized) Error:</strong> you must pass a controller in Liquid render call; <br/>
              e.g. Liquid::Template.parse(\"{{ movies | will_paginate_liquid }}\").render({'movies' => @movies}, :registers => {:controller => @controller})</p>" unless @options[:controller]
      
      links = @options[:page_links] ? windowed_links : []
      # previous/next buttons added in to the links collection
      links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
      links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
      
      html = links.join(@options[:separator])
      html_attributes.delete(:controller)
      @options[:container] ? content_tag(:div, html, html_attributes) : html
    end
    
    def page_link(page, text, attributes = {})
      link_to text, url_for_page(page), attributes
    end

    def page_span(page, text, attributes = {})
      content_tag :span, text, attributes
    end
              
    def url_for_page(page)
      page_one = page == 1
      unless @url_string and !page_one
        @url_params = {}
        @controller = @options[:controller]
        # page links should preserve GET parameters
        stringified_merge @url_params, @controller.params if @controller && @controller.request.get? && @controller.params
        stringified_merge @url_params, @options[:params] if @options[:params]
        
        if complex = param_name.index(/[^\w-]/)
          page_param = (defined?(CGIMethods) ? CGIMethods : ActionController::AbstractRequest).
            parse_query_parameters("#{param_name}=#{page}")
          
          stringified_merge @url_params, page_param
        else
          @url_params[param_name] = page_one ? 1 : 2
        end

        url = @controller.url_for(@url_params)
        url = "#{url}##{@options[:params][:anchor]}" if @options[:params] && @options[:params][:anchor]
        return url if page_one
        
        if complex
          @url_string = url.sub(%r!((?:\?|&amp;)#{CGI.escape param_name}=)#{page}!, '\1@')
          return url
        else
          @url_string = url
          @url_params[param_name] = 3
          @controller.url_for(@url_params).split(//).each_with_index do |char, i|
            if char == '3' and url[i, 1] == '2'
              @url_string[i] = '@'
              break
            end
          end
        end
      end
      # finally!
      @url_string.sub '@', page.to_s
    end
  end  
end        
