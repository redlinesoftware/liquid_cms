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

  def uses_random(&block)
    collection = []

    # random sql func supported by postgresql and sqlite (perhaps others)
    random_func = "random()"

    begin
      collection = yield random_func
    rescue ActiveRecord::StatementInvalid => e
      if options[:random] == true
        # the random function used was invalid, so we'll try an alternative syntax for mysql (perhaps others)
        mysql_func = "rand()"

        if random_func != mysql_func
          random_func = mysql_func
        else
          # set random to false and just use the default order since the alt didn't work either
          options[:random] = false
        end

        # retry the query
        retry
      end
    end

    collection
  end
end
