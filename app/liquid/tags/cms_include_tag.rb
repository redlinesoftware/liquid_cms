# a modified include tag from the default liquid one
# includes content from oather page neames

module Liquid
  class Include < Liquid::Tag
    def render(context)
      template_name = context[@template_name]
      raise FileSystemError, "Illegal page template name '#{template_name}'" unless template_name =~ Cms::Page::NAME_REGEX

      page = context.registers[:context].pages.find_by_name(template_name)
      raise FileSystemError, "No such page template '#{template_name}'" if page.nil?
      
      source  = page.content
      partial = Liquid::Template.parse(source)

      variable = context[@variable_name || template_name]

      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        if variable.is_a?(Array)
          
          variable.collect do |variable|            
            context[template_name] = variable
            partial.render(context)
          end

        else
                    
          context[template_name] = variable
          partial.render(context)
          
        end
      end
    end
  end
end
