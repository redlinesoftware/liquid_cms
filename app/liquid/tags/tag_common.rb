module Cms
  module TagCommon
    extend ActiveSupport::Memoizable

    HyphenatedTagAttributes = /([\w-]+)\s*\:\s*(#{Liquid::QuotedFragment})/

    def parse_options(context, markup)
      begin
        options = HashWithIndifferentAccess.new
        return options if markup.blank?

        markup.scan(HyphenatedTagAttributes) do |key, value|
          options[key.to_sym] = context[value]
        end

        options
      rescue ArgumentError => e
        raise SyntaxError.new("Syntax Error in 'tag options' - Valid syntax: name:value")
      end
    end

    def context_object(context)
      context.registers[:context].object
    end
    memoize :context_object

    def params(context)
      context.registers[:controller].params.except(:controller, :action)
    end
  end
end
