class Cms::DataTag < Liquid::Tag
  module TagMethods
    extend Cms::TagCommon
  end

  attr_reader :context
  attr_reader :options

  def initialize(tag_name, markup, tokens)
    @markup = markup
    super
  end

  def context_object
    TagMethods.context_object(@context)
  end

  def params
    TagMethods.params(@context)
  end

  def render(context)
    @context = context
    @options = TagMethods.parse_options(context, @markup)

    get_data do |name, data|
      context[@options[:as] || name] = data
    end
    ''
  end 
end
