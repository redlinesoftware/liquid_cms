class UserDataTag < Liquid::Tag
  attr_reader :context

  def company
    context.registers[:context].object
  end

  def render(context)
    @context = context
    context['users'] = company.users
    ''
  end 
end

Liquid::Template.register_tag('user_data', UserDataTag)
