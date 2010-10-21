# a modified include tag from the default liquid one
# includes content from oather page neames

module Liquid
  class Include < Liquid::Tag
    Syntax = /(#{QuotedFragment}+)?/

    def initialize(tag_name, markup, tokens)      
      if markup =~ Syntax
        @template_name = $1
      else
        raise SyntaxError.new("Error in tag 'include' - Valid syntax: include '[template]'")
      end

      super
    end

    def render(context)
      template = context[@template_name]
      raise FileSystemError, "Illegal template name '#{template}'" unless template =~ Cms::Page::NAME_REGEX

      page = context.registers[:context].pages.find_by_name(template)
      raise FileSystemError, "No such template '#{template}'" if page.nil?
      
      source  = page.content
      partial = Liquid::Template.parse(source)

      context.stack do
        partial.render(context)
      end
    end
  end
end
