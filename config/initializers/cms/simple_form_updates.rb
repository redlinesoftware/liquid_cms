class SimpleForm::FormBuilder
  def commit_button_or_cancel
    template.content_tag :div, :class => 'buttons' do
      String.new.tap do |html|
        html << button(:submit)
        html << " or "
        html << template.link_to(template.t('simple_form.buttons.cancel'), :back, :class => 'cancel')
      end.html_safe
    end
  end
end

module SimpleForm
  module Inputs
    class Base
      def translate_with_html_safe(namespace, default='')
        t = translate_without_html_safe(namespace, default)
        t ? t.html_safe : t
      end
      alias_method_chain :translate, :html_safe
    end
  end
end
