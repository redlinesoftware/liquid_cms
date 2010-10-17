module Liquid
  class Include < Liquid::Tag
    def render(context)
      raise FileSystemError, "Illegal template name '#{@template_name}'" unless @template_name =~ Cms::Page::NAME_REGEX

      page = context.registers[:context].pages.find_by_name(@template_name)
      raise FileSystemError, "No such template '#{@template_name}'" if page.nil?
      
      source  = page.content
      partial = Liquid::Template.parse(source)

      variable = context[@variable_name || @template_name[1..-2]]

      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        if variable.is_a?(Array)
          variable.collect do |variable|
            context[@template_name[1..-2]] = variable
            partial.render(context)
          end
        else
          context[@template_name[1..-2]] = variable
          partial.render(context)
        end
      end
    end
  end
end
